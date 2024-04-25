package com.clova;

import com.clova.grpc.proto.NestConfig;
import com.clova.grpc.proto.NestData;
import com.clova.grpc.proto.NestRequest;
import com.clova.grpc.proto.NestResponse;
import com.clova.grpc.proto.NestServiceGrpc;
import com.clova.grpc.proto.RequestType;
import com.google.protobuf.ByteString;
import io.grpc.ManagedChannel;
import io.grpc.Metadata;
import io.grpc.StatusRuntimeException;
import io.grpc.netty.NettyChannelBuilder;
import io.grpc.stub.MetadataUtils;
import io.grpc.stub.StreamObserver;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.concurrent.CountDownLatch;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class ClovaApplication {

    private static final Logger logger = LoggerFactory.getLogger(ClovaApplication.class);
    public static void main(String[] args) throws Exception, IOException {

        CountDownLatch latch = new CountDownLatch(1);
        ManagedChannel channel = NettyChannelBuilder
//            .forTarget("clovaspeech-gw.ncloud.com:50051")
            .forTarget("clovaspeech-gw.ncloud.com/external/v1/7632/ce61c24d820f08fbc511e01ad4160c908b53484961f6e73d80a74d7ebd7daeac")
            .useTransportSecurity()
            .build();
        NestServiceGrpc.NestServiceStub client = NestServiceGrpc.newStub(channel);
        Metadata metadata = new Metadata();
        metadata.put(Metadata.Key.of("Authorization", Metadata.ASCII_STRING_MARSHALLER),
            "Bearer e4bde1dd90764fdd8189813b267b204f");
        client = MetadataUtils.attachHeaders(client, metadata);

        StreamObserver<NestResponse> responseObserver = new StreamObserver<NestResponse>() {
            @Override
            public void onNext(NestResponse response) {
                // 로그로 확인
                logger.info("Received response: " + response.getContents());

                // 여기서 응답으로 받은 텍스트 출력
                System.out.println("Received response: " + response.getContents());
            }

            @Override
            public void onError(Throwable t) {
                // 로그로 확인
                logger.error("Stream encountered an error: " + t.getMessage());

                if(t instanceof StatusRuntimeException) {
                    StatusRuntimeException error = (StatusRuntimeException) t;
                    System.out.println("Error: " + error.getStatus().getDescription());
                    error.printStackTrace(); // 스택 트레이스를 출력하여 에러의 상세 정보 확인
                } else {
                    t.printStackTrace(); // 예상치 못한 예외의 상세 정보를 출력
                }
                latch.countDown();
            }

            @Override
            public void onCompleted() {
                // 로그로 확인
                logger.info("Streaming completed.");

                latch.countDown();
            }
        };

        StreamObserver<NestRequest> requestObserver = client.recognize(responseObserver);

        requestObserver.onNext(NestRequest.newBuilder()
            .setType(RequestType.CONFIG)
            .setConfig(NestConfig.newBuilder()
                .setConfig("{\"transcription\":{\"language\":\"ko\"}}")
                .build())
            .build());

        java.io.File file = new java.io.File("C:/Users/SSAFY/Desktop/test.wav");
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
    }
}
	

