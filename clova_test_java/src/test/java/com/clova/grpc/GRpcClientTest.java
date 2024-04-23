package com.clova.grpc;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import com.clova.grpc.proto.*;
import io.grpc.stub.StreamObserver;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

class GRpcClientTest {

    @Test
    void testApiCommunication() throws Exception {
        // gRPC 스텁과 메타데이터 설정
        NestServiceGrpc.NestServiceStub mockStub = Mockito.mock(NestServiceGrpc.NestServiceStub.class);
        GRpcClient client = new GRpcClient();
        client.setClient(mockStub); // GRpcClient 클래스에 setClient 메서드 추가 필요

        // Mock response observer
        StreamObserver<NestResponse> mockResponseObserver = new StreamObserver<>() {
            @Override
            public void onNext(NestResponse value) {
                System.out.println("Mock Response Received: " + value.getContents());
                // 검증 로직 추가
                assertEquals("Expected response", value.getContents());
            }

            @Override
            public void onError(Throwable t) {
                System.out.println("Error in mock response");
            }

            @Override
            public void onCompleted() {
                System.out.println("Mock stream completed");
            }
        };

        // 스트림 옵저버 구성을 모킹
        doAnswer(invocation -> {
            StreamObserver<NestRequest> requestObserver = invocation.getArgument(0);
            // 클라이언트가 요청을 보낼 때 예상되는 행동 모킹
            requestObserver.onNext(NestRequest.newBuilder().setType(RequestType.CONFIG).build());
            requestObserver.onCompleted();
            return null;
        }).when(mockStub).recognize(any());

        // 테스트 실행
        client.testApiConnection(); // GRpcClient 클래스에 testApiConnection 메서드 추가 필요
    }
}

