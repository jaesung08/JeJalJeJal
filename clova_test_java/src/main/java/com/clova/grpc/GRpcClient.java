package com.clova.grpc;

import com.clova.grpc.proto.NestConfig;
import com.clova.grpc.proto.NestData;
import com.clova.grpc.proto.NestRequest;
import com.clova.grpc.proto.NestResponse;
import com.clova.grpc.proto.NestServiceGrpc;
import com.clova.grpc.proto.NestServiceGrpc.NestServiceStub;
import com.clova.grpc.proto.RequestType;
import com.google.protobuf.ByteString;
import io.grpc.ManagedChannel;
import io.grpc.Metadata;
import io.grpc.StatusRuntimeException;
import io.grpc.netty.NettyChannelBuilder;
import io.grpc.stub.MetadataUtils;
import io.grpc.stub.StreamObserver;
import java.io.FileInputStream;
import java.util.concurrent.CountDownLatch;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GRpcClient {
    private static final Logger logger = LoggerFactory.getLogger(GRpcClient.class);
    private NestServiceStub client;

    public static void main(String[] args) throws Exception {
        CountDownLatch latch = new CountDownLatch(1);
        ManagedChannel channel = NettyChannelBuilder
            .forTarget("clovaspeech-gw.ncloud.com:50051")
            .useTransportSecurity()
            .build();
        logger.info("Channel established to clovaspeech-gw.ncloud.com:50051");

        NestServiceGrpc.NestServiceStub client = NestServiceGrpc.newStub(channel);
        Metadata metadata = new Metadata();
        metadata.put(Metadata.Key.of("Authorization", Metadata.ASCII_STRING_MARSHALLER),
            "Bearer fuT1OO0o9jBcEw3kFuqD9rqQ3kkYKUzBX0CnTGNP");  // Replace `your_secret_key` with the actual secret key.
        client = MetadataUtils.attachHeaders(client, metadata);
        logger.info("Metadata attached and client stub prepared.");

        StreamObserver<NestResponse> responseObserver = new StreamObserver<NestResponse>() {
            @Override
            public void onNext(NestResponse response) {
                logger.info("Received response: " + response.getContents());
            }

            @Override
            public void onError(Throwable t) {
                if (t instanceof StatusRuntimeException) {
                    StatusRuntimeException error = (StatusRuntimeException) t;
                    logger.error("API Error: " + error.getStatus().getDescription());
                }
                latch.countDown();
            }

            @Override
            public void onCompleted() {
                logger.info("Stream completed");
                latch.countDown();
            }
        };

        StreamObserver<NestRequest> requestObserver = client.recognize(responseObserver);
        // Config request
        requestObserver.onNext(NestRequest.newBuilder()
            .setType(RequestType.CONFIG)
            .setConfig(NestConfig.newBuilder()
                .setConfig("{\"transcription\":{\"language\":\"ko\"}}")
                .build())
            .build());
        // Data streaming
        java.io.File file = new java.io.File("~/media/42s.wav");
        byte[] buffer = new byte[32000];
        int bytesRead;
        FileInputStream inputStream = new FileInputStream(file);
        while ((bytesRead = inputStream.read(buffer)) != -1) {
            requestObserver.onNext(NestRequest.newBuilder()
                .setType(RequestType.DATA)
                .setData(NestData.newBuilder()
                    .setChunk(ByteString.copyFrom(buffer, 0, bytesRead))
                    .setExtraContents("{ \"seqId\": 0, \"epFlag\": false}")
                    .build())
                .build());
        }
        requestObserver.onCompleted();
        latch.await();
        channel.shutdown();
        logger.info("Channel shutdown completed.");
    }

    public void setClient(NestServiceGrpc.NestServiceStub stub) {
        this.client = stub;  // 'client'는 GRpcClient 클래스의 멤버 변수입니다.
    }


    public void testApiConnection() {
        // 설정된 client를 사용하여 gRPC 호출을 시뮬레이션
        StreamObserver<NestResponse> responseObserver = new StreamObserver<NestResponse>() {
            @Override
            public void onNext(NestResponse value) {
                System.out.println("Response from server: " + value.getContents());
            }

            @Override
            public void onError(Throwable t) {
                t.printStackTrace();
            }

            @Override
            public void onCompleted() {
                System.out.println("Server completed sending data");
            }
        };

        // 서버로 요청을 시작합니다.
        StreamObserver<NestRequest> requestObserver = client.recognize(responseObserver);
        // 요청 데이터 전송 예시
        requestObserver.onNext(NestRequest.newBuilder().setType(RequestType.CONFIG).build());
        requestObserver.onCompleted();  // 요청 완료
    }

}
