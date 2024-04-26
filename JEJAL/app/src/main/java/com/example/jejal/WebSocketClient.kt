import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import okio.ByteString

class WebSocketClient(url: String) {
    private var client = OkHttpClient()
    private lateinit var webSocket: WebSocket

    private val listener = object : WebSocketListener() {
        override fun onOpen(webSocket: WebSocket, response: okhttp3.Response) {
            // 연결이 성공적으로 열렸을 때 호출
        }

        override fun onMessage(webSocket: WebSocket, text: String) {
            // 메시지를 받았을 때 호출
        }

        override fun onMessage(webSocket: WebSocket, bytes: ByteString) {
            // 바이너리 메시지를 받았을 때 호출
        }

        override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
            // 서버가 연결 종료를 시작할 때 호출
            webSocket.close(1000, null)
        }

        override fun onFailure(webSocket: WebSocket, t: Throwable, response: okhttp3.Response?) {
            // 연결 오류가 발생했을 때 호출
        }
    }

    fun start() {
//        val request = Request.Builder().url(url).build()
//        webSocket = client.newWebSocket(request, listener)
    }

    fun send(message: String) {
        webSocket.send(message)
    }

    fun send(bytes: ByteString) {
        webSocket.send(bytes)
    }

    fun close() {
        webSocket.close(1000, "Closing Connection")
    }
}
