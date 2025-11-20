import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF111936).withOpacity(0.6),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink(context, 'About', () {}),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 12,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(width: 16),
              _buildFooterLink(context, 'Privacy', () {}),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 12,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(width: 16),
              _buildFooterLink(context, 'Help', () {}),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 16,
                color: const Color(0xFF27E8A7),
              ),
              const SizedBox(width: 8),
              Text(
                '© 2025 Shopping List',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFFB8B8D1),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF27E8A7), Color(0xFF8B5CF6)],
            ).createShader(bounds),
            child: Text(
              'Made with Flutter',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF27E8A7),
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
