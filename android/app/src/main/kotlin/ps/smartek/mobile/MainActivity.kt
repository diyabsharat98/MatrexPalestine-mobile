package ps.smartek.mobile

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth's Android BiometricPrompt integration requires a
// FragmentActivity host — plain FlutterActivity silently fails to show
// the native fingerprint dialog (the button does nothing on a real device).
class MainActivity : FlutterFragmentActivity()
