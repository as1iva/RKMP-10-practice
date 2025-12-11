import 'package:url_launcher/url_launcher.dart';

class FeedbackService {
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: to,
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw Exception('Could not launch email client');
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
