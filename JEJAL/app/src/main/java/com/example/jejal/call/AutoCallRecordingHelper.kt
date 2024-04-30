import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity

object AutoCallRecordingHelper {
    const val AUTO_CALL_RECORDING_SETTING_REQUEST_CODE = 100

    fun showAutoCallRecordingMessage(context: AppCompatActivity, onSettingsClicked: (Context) -> Unit) {
        val message = "앱을 사용하려면 통화 자동 녹음 기능을 활성화해야 합니다.\n\n" +
                "1. 휴대폰 설정으로 이동합니다.\n" +
                "2. '통화' 메뉴를 찾아 선택합니다.\n" +
                "3. '통화 녹음' 옵션을 선택합니다.\n" +
                "4. '통화 자동 녹음' 스위치를 켭니다.\n\n" +
                "설정을 완료한 후 앱으로 돌아와 주세요."

        val builder = AlertDialog.Builder(context)
        builder.setTitle("통화 자동 녹음 활성화 안내")
            .setMessage(message)
            .setPositiveButton("설정으로 이동") { dialog, _ ->
                onSettingsClicked(context)
                dialog.dismiss()
            }
            .setNegativeButton("취소") { dialog, _ ->
                dialog.dismiss()
            }
            .create()
            .show()
    }

    fun openAutoCallRecordingSettings(context: Context) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        val uri = Uri.fromParts("package", context.packageName, null)
        intent.data = uri
        if(context is AppCompatActivity) {
            context.startActivityForResult(intent, AUTO_CALL_RECORDING_SETTING_REQUEST_CODE)
        }
    }

    fun handleActivityResult(resultCode: Int, context: Context): Boolean {
        if (resultCode == Activity.RESULT_OK) {
            if (isAutoCallRecordingEnabled(context)) {
                showAutoCallRecordingEnabledMessage(context)
            } else {
                showAutoCallRecordingDisabledMessage(context)
            }
            return true
        }
        return false
    }

    private fun isAutoCallRecordingEnabled(context: Context): Boolean {
        val packageName = context.packageName
        val autoCallRecordingEnabled = Settings.System.getInt(
            context.contentResolver,
            "auto_call_recording_enabled_$packageName",
            0
        ) == 1
        return autoCallRecordingEnabled
    }

    private fun showAutoCallRecordingEnabledMessage(context: Context) {
        val builder = AlertDialog.Builder(context)
        builder.setTitle("통화 자동 녹음 활성화 완료")
            .setMessage("통화 자동 녹음 기능이 활성화되었습니다. 이제 앱을 사용할 수 있습니다.")
            .setPositiveButton("확인") { dialog, _ ->
                dialog.dismiss()
            }
            .create()
            .show()
    }

    private fun showAutoCallRecordingDisabledMessage(context: Context) {
        val builder = AlertDialog.Builder(context)
        builder.setTitle("통화 자동 녹음 비활성화")
            .setMessage("통화 자동 녹음 기능이 비활성화되었습니다. 앱을 사용하려면 통화 자동 녹음 기능을 활성화해야 합니다.")
            .setPositiveButton("설정으로 이동") { dialog, _ ->
                openAutoCallRecordingSettings(context)
                dialog.dismiss()
            }
            .setNegativeButton("취소") { dialog, _ ->
                dialog.dismiss()
            }
            .create()
            .show()
    }
}