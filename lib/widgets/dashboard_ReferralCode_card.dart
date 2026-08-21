import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReferralCodeCard extends StatelessWidget {
  const ReferralCodeCard({
    super.key,
    required this.referralCode,
    this.onViewProgram,
  });

  final String referralCode;
  final VoidCallback? onViewProgram;

  bool get _hasCode => referralCode.trim().isNotEmpty;

  Future<void> _copyCode(BuildContext context) async {
    if (!_hasCode) return;
    await Clipboard.setData(ClipboardData(text: referralCode));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Referral code copied')));
  }

  Future<void> _shareCode(BuildContext context) async {
    if (!_hasCode) return;
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      'Join NavYoga Academy with my referral code $referralCode and start your wellness journey today.',
      subject: 'Join me on NavYoga Academy',
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'YOUR REFERRAL CODE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _hasCode ? () => _copyCode(context) : null,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _hasCode ? referralCode : 'Code unavailable',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _hasCode ? Colors.white : Colors.white60,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: _hasCode ? 1.4 : 0,
                    ),
                  ),
                ),
                if (_hasCode)
                  const Icon(Icons.copy_rounded, color: Colors.white70, size: 19),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _hasCode ? () => _shareCode(context) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6D28D9),
                    disabledBackgroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text('Invite friends', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              if (onViewProgram != null) ...[
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: onViewProgram,
                  tooltip: 'View referral program',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.16),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
