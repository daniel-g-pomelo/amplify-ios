//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest
import Combine

@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSPluginsCore
@testable import AWSDataStoreCategoryPlugin

class ModelSyncedEventEmitterTests: XCTestCase {

    var initialSyncOrchestrator: MockAWSInitialSyncOrchestrator?
    var reconciliationQueue: MockAWSIncomingEventReconciliationQueue?

    override func setUp() {
        initialSyncOrchestrator = MockAWSInitialSyncOrchestrator(dataStoreConfiguration: .default,
                                                                 api: nil,
                                                                 reconciliationQueue: nil,
                                                                 storageAdapter: nil)
        reconciliationQueue = MockAWSIncomingEventReconciliationQueue(modelSchemas: [Post.schema],
                                                                      api: nil,
                                                                      storageAdapter: nil,
                                                                      syncExpressions: [],
                                                                      auth: nil)
        ModelRegistry.register(modelType: Post.self)
    }

    /// ModelSyncedEventEmitter should continue to send `mutationEventApplied` and `mutationEventDropped` events even
    /// after ModelSyncedEvent has been emitted.
    ///
    /// - Given: Initial sync enqueue 2 models, then reconcile 8 models (5 applied, 3 dropped)
    /// - When:
    ///    - ModelSyncedEventEmitter processes the enqueued and reconciled models.
    /// - Then:
    ///    - Hub event "ModelSyncedEvent" is sent out and subscriber receives all reconciled events.
    ///
    func testSuccess() throws {
        let modelSyncedReceived = expectation(description: "modelSynced received")
        let modelSyncedReceivedFromHub = expectation(description: "modelSynced received from Hub")
        let mutationEventAppliedReceived = expectation(description: "mutationEventApplied received")
        mutationEventAppliedReceived.expectedFulfillmentCount = 5
        let mutationEventDroppedReceived = expectation(description: "mutationEventDropped received")
        mutationEventDroppedReceived.expectedFulfillmentCount = 3
        let anyPostMetadata = MutationSyncMetadata(id: "1",
                                                   deleted: false,
                                                   lastChangedAt: Int(Date().timeIntervalSince1970),
                                                   version: 1)
        let testPost = Post(id: "1", title: "post1", content: "content", createdAt: .now())
        let anyPost = AnyModel(testPost)
        let anyPostMutationSync = MutationSync<AnyModel>(model: anyPost, syncMetadata: anyPostMetadata)
        let postMutationEvent = try MutationEvent(untypedModel: testPost, mutationType: .create)

        let listener = Amplify.Hub.publisher(for: .dataStore).sink { payload in
            switch payload.eventName {
            case HubPayload.EventName.DataStore.modelSynced:
                guard let modelSyncedEventPayload = payload.data as? ModelSyncedEvent else {
                    XCTFail("Couldn't cast payload data as ModelSyncedEvent")
                    return
                }
                let expectedModelSyncedEventPayload = ModelSyncedEvent(modelName: "Post",
                                                                       isFullSync: true,
                                                                       isDeltaSync: false,
                                                                       added: 2,
                                                                       updated: 0,
                                                                       deleted: 0)
                XCTAssertEqual(modelSyncedEventPayload, expectedModelSyncedEventPayload)
                modelSyncedReceivedFromHub.fulfill()
            default:
                break
            }
        }

        let emitter = ModelSyncedEventEmitter(modelSchema: Post.schema,
                                              initialSyncOrchestrator: initialSyncOrchestrator,
                                              reconciliationQueue: reconciliationQueue)

        var emitterSink: AnyCancellable?
        emitterSink = emitter.publisher.sink { _ in
            XCTFail("Should not have completed")
        } receiveValue: { value in
            switch value {
            case .modelSyncedEvent:
                modelSyncedReceived.fulfill()
            case .mutationEventApplied:
                mutationEventAppliedReceived.fulfill()
            case .mutationEventDropped:
                mutationEventDroppedReceived.fulfill()
            }
        }

        initialSyncOrchestrator?.initialSyncOrchestratorTopic.send(.started(modelName: Post.modelName,
                                                                            syncType: .fullSync))
        initialSyncOrchestrator?.initialSyncOrchestratorTopic.send(.enqueued(anyPostMutationSync,
                                                                             modelName: Post.modelName))
        initialSyncOrchestrator?.initialSyncOrchestratorTopic.send(.enqueued(anyPostMutationSync,
                                                                             modelName: Post.modelName))
        initialSyncOrchestrator?.initialSyncOrchestratorTopic.send(.finished(modelName: Post.modelName))
        reconciliationQueue?.incomingEventSubject.send(.mutationEventApplied(postMutationEvent))
        reconciliationQueue?.incomingEventSubject.send(.mutationEventApplied(postMutationEvent))
        reconciliationQueue?.incomingEventSubject.send(.mutationEventApplied(postMutationEvent))
        reconciliationQueue?.incomingEventSubject.send(.mutationEventApplied(postMutationEvent))
        reconciliationQueue?.incomingEventSubject.send(.mutationEventApplied(postMutationEvent))
        reconciliationQueue?.incomingEventSubject.send(.mutationEventDropped(modelName: Post.modelName))
        reconciliationQueue?.incomingEventSubject.send(.mutationEventDropped(modelName: Post.modelName))
        reconciliationQueue?.incomingEventSubject.send(.mutationEventDropped(modelName: Post.modelName))

        waitForExpectations(timeout: 1)
        emitterSink?.cancel()
        listener.cancel()
    }
}
