package com.clova.grpc;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.google.protobuf.ByteString;
import com.clova.grpc.proto.NestConfig;
import com.clova.grpc.proto.NestData;
import com.clova.grpc.proto.NestRequest;
import com.clova.grpc.proto.NestResponse;
import com.clova.grpc.proto.NestServiceGrpc;
import com.clova.grpc.proto.RequestType;
import io.grpc.ManagedChannel;
import io.grpc.Metadata;
import io.grpc.StatusRuntimeException;
import io.grpc.netty.NettyChannelBuilder;
import io.grpc.stub.MetadataUtils;
import io.grpc.stub.StreamObserver;
import java.io.FileInputStream;
import java.util.concurrent.CountDownLatch;

public class GRpcClient {
    private static final Logger logger = LoggerFactory.getLogger(GRpcClient.class);

    public static void main(String[] args) throws Exception {
        CountDownLatch latch = new CountDownLatch(1);
        ManagedChannel channel = NettyChannelBuilder
            .forTarget("clovaspeech-gw.ncloud.com:50051")
            .useTransportSecurity()
            .build();
        NestServiceGrpc.NestServiceStub client = NestServiceGrpc.newStub(channel);
        Metadata metadata = new Metadata();
        metadata.put(Metadata.Key.of("Authorization", Metadata.ASCII_STRING_MARSHALLER),
            "Bearer fuT1OO0o9jBcEw3kFuqD9rqQ3kkYKUzBX0CnTGNP");  // Replace `your_secret_key` with the actual secret key.
        client = MetadataUtils.attachHeaders(client, metadata);

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
    }
}
