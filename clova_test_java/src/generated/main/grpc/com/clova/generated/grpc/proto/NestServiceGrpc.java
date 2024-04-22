package com.clova.generated.grpc.proto;

import static io.grpc.MethodDescriptor.generateFullMethodName;

/**
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.35.0)",
    comments = "Source: nest.proto")
public final class NestServiceGrpc {

  private NestServiceGrpc() {}

  public static final String SERVICE_NAME = "com.clova.generated.grpc.proto.NestService";

  // Static method descriptors that strictly reflect the proto.
  private static volatile io.grpc.MethodDescriptor<com.clova.generated.grpc.proto.NestRequest,
      com.clova.generated.grpc.proto.NestResponse> getRecognizeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "recognize",
      requestType = com.clova.generated.grpc.proto.NestRequest.class,
      responseType = com.clova.generated.grpc.proto.NestResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.BIDI_STREAMING)
  public static io.grpc.MethodDescriptor<com.clova.generated.grpc.proto.NestRequest,
      com.clova.generated.grpc.proto.NestResponse> getRecognizeMethod() {
    io.grpc.MethodDescriptor<com.clova.generated.grpc.proto.NestRequest, com.clova.generated.grpc.proto.NestResponse> getRecognizeMethod;
    if ((getRecognizeMethod = NestServiceGrpc.getRecognizeMethod) == null) {
      synchronized (NestServiceGrpc.class) {
        if ((getRecognizeMethod = NestServiceGrpc.getRecognizeMethod) == null) {
          NestServiceGrpc.getRecognizeMethod = getRecognizeMethod =
              io.grpc.MethodDescriptor.<com.clova.generated.grpc.proto.NestRequest, com.clova.generated.grpc.proto.NestResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.BIDI_STREAMING)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "recognize"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.clova.generated.grpc.proto.NestRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.clova.generated.grpc.proto.NestResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NestServiceMethodDescriptorSupplier("recognize"))
              .build();
        }
      }
    }
    return getRecognizeMethod;
  }

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static NestServiceStub newStub(io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<NestServiceStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<NestServiceStub>() {
        @java.lang.Override
        public NestServiceStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new NestServiceStub(channel, callOptions);
        }
      };
    return NestServiceStub.newStub(factory, channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static NestServiceBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<NestServiceBlockingStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<NestServiceBlockingStub>() {
        @java.lang.Override
        public NestServiceBlockingStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new NestServiceBlockingStub(channel, callOptions);
        }
      };
    return NestServiceBlockingStub.newStub(factory, channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary calls on the service
   */
  public static NestServiceFutureStub newFutureStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<NestServiceFutureStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<NestServiceFutureStub>() {
        @java.lang.Override
        public NestServiceFutureStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new NestServiceFutureStub(channel, callOptions);
        }
      };
    return NestServiceFutureStub.newStub(factory, channel);
  }

  /**
   */
  public static abstract class NestServiceImplBase implements io.grpc.BindableService {

    /**
     */
    public io.grpc.stub.StreamObserver<com.clova.generated.grpc.proto.NestRequest> recognize(
        io.grpc.stub.StreamObserver<com.clova.generated.grpc.proto.NestResponse> responseObserver) {
      return io.grpc.stub.ServerCalls.asyncUnimplementedStreamingCall(getRecognizeMethod(), responseObserver);
    }

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
          .addMethod(
            getRecognizeMethod(),
            io.grpc.stub.ServerCalls.asyncBidiStreamingCall(
              new MethodHandlers<
                com.clova.generated.grpc.proto.NestRequest,
                com.clova.generated.grpc.proto.NestResponse>(
                  this, METHODID_RECOGNIZE)))
          .build();
    }
  }

  /**
   */
  public static final class NestServiceStub extends io.grpc.stub.AbstractAsyncStub<NestServiceStub> {
    private NestServiceStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected NestServiceStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new NestServiceStub(channel, callOptions);
    }

    /**
     */
    public io.grpc.stub.StreamObserver<com.clova.generated.grpc.proto.NestRequest> recognize(
        io.grpc.stub.StreamObserver<com.clova.generated.grpc.proto.NestResponse> responseObserver) {
      return io.grpc.stub.ClientCalls.asyncBidiStreamingCall(
          getChannel().newCall(getRecognizeMethod(), getCallOptions()), responseObserver);
    }
  }

  /**
   */
  public static final class NestServiceBlockingStub extends io.grpc.stub.AbstractBlockingStub<NestServiceBlockingStub> {
    private NestServiceBlockingStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected NestServiceBlockingStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new NestServiceBlockingStub(channel, callOptions);
    }
  }

  /**
   */
  public static final class NestServiceFutureStub extends io.grpc.stub.AbstractFutureStub<NestServiceFutureStub> {
    private NestServiceFutureStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected NestServiceFutureStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new NestServiceFutureStub(channel, callOptions);
    }
  }

  private static final int METHODID_RECOGNIZE = 0;

  private static final class MethodHandlers<Req, Resp> implements
      io.grpc.stub.ServerCalls.UnaryMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ServerStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ClientStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.BidiStreamingMethod<Req, Resp> {
    private final NestServiceImplBase serviceImpl;
    private final int methodId;

    MethodHandlers(NestServiceImplBase serviceImpl, int methodId) {
      this.serviceImpl = serviceImpl;
      this.methodId = methodId;
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public void invoke(Req request, io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        default:
          throw new AssertionError();
      }
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public io.grpc.stub.StreamObserver<Req> invoke(
        io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        case METHODID_RECOGNIZE:
          return (io.grpc.stub.StreamObserver<Req>) serviceImpl.recognize(
              (io.grpc.stub.StreamObserver<com.clova.generated.grpc.proto.NestResponse>) responseObserver);
        default:
          throw new AssertionError();
      }
    }
  }

  private static abstract class NestServiceBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoFileDescriptorSupplier, io.grpc.protobuf.ProtoServiceDescriptorSupplier {
    NestServiceBaseDescriptorSupplier() {}

    @java.lang.Override
    public com.google.protobuf.Descriptors.FileDescriptor getFileDescriptor() {
      return com.clova.generated.grpc.proto.Nest.getDescriptor();
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.ServiceDescriptor getServiceDescriptor() {
      return getFileDescriptor().findServiceByName("NestService");
    }
  }

  private static final class NestServiceFileDescriptorSupplier
      extends NestServiceBaseDescriptorSupplier {
    NestServiceFileDescriptorSupplier() {}
  }

  private static final class NestServiceMethodDescriptorSupplier
      extends NestServiceBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoMethodDescriptorSupplier {
    private final String methodName;

    NestServiceMethodDescriptorSupplier(String methodName) {
      this.methodName = methodName;
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.MethodDescriptor getMethodDescriptor() {
      return getServiceDescriptor().findMethodByName(methodName);
    }
  }

  private static volatile io.grpc.ServiceDescriptor serviceDescriptor;

  public static io.grpc.ServiceDescriptor getServiceDescriptor() {
    io.grpc.ServiceDescriptor result = serviceDescriptor;
    if (result == null) {
      synchronized (NestServiceGrpc.class) {
        result = serviceDescriptor;
        if (result == null) {
          serviceDescriptor = result = io.grpc.ServiceDescriptor.newBuilder(SERVICE_NAME)
              .setSchemaDescriptor(new NestServiceFileDescriptorSupplier())
              .addMethod(getRecognizeMethod())
              .build();
        }
      }
    }
    return result;
  }
}
