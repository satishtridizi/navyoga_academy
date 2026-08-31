import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/LiveClassData.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';

class YttLiveClassesScreen extends StatelessWidget {
  const YttLiveClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = LiveClassData(
      enrolled: false,
      title: 'My YTT Live Classes',
      description:
          'Live yoga teacher training sessions and recordings from your enrolled cohorts.',
    );

    return AppScaffold(
      currentIndex: 0,
      drawer: const CustomDrawer(
        currentPage: 'YTT Live Classes',
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) {
            return IconButton(
              tooltip: 'Menu',
              icon: const Icon(
                Icons.menu,
                color: Color(0xFF1E1B39),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 56,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth < 600 ? 16.0 : 24.0;

            return RefreshIndicator(
              onRefresh: () async {

              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1000,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HeaderSection(
                          data: data,
                          onEnrollTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.payments,
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        if (!data.enrolled)
                          EmptyStateSection(
                            description:
                                'Enroll in a YTT Live course from the plans page to access live sessions and recordings.',
                            onViewPlansTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.payments,
                              );
                            },
                          )
                        else
                          const EnrolledStateSection(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final LiveClassData data;
  final VoidCallback onEnrollTap;

  const HeaderSection({
    super.key,
    required this.data,
    required this.onEnrollTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF97316),
            Color(0xFF7B2CBF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 680;

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleContent(),
                const SizedBox(height: 20),
                _buildStatusCard(
                  expandWidth: true,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: _buildTitleContent(),
              ),
              const SizedBox(width: 24),
              Flexible(
                flex: 2,
                child: _buildStatusCard(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitleContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
            ),
          ),
          child: const Icon(
            Icons.school_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          data.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          data.description,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.90),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    bool expandWidth = false,
  }) {
    return Container(
      width: expandWidth ? double.infinity : null,
      constraints: const BoxConstraints(
        minWidth: 245,
        maxWidth: 330,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: data.enrolled
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  data.enrolled
                      ? Icons.verified_outlined
                      : Icons.lock_outline,
                  color: data.enrolled
                      ? Colors.green
                      : const Color(0xFFF97316),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enrollment Status',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.enrolled
                          ? 'Enrolled'
                          : 'Not enrolled',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: data.enrolled
                            ? Colors.green
                            : const Color(0xFF1E1B39),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  data.enrolled ? null : onEnrollTap,
              icon: Icon(
                data.enrolled
                    ? Icons.check_circle_outline
                    : Icons.workspace_premium_outlined,
                size: 20,
              ),
              label: Text(
                data.enrolled
                    ? 'Already Enrolled'
                    : 'Enroll Now',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFB7A34),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    Colors.green.shade100,
                disabledForegroundColor:
                    Colors.green.shade800,
                elevation: data.enrolled ? 0 : 3,
                minimumSize: const Size(
                  double.infinity,
                  48,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateSection extends StatelessWidget {
  final VoidCallback onViewPlansTap;
  final String description;

  const EmptyStateSection({
    super.key,
    required this.onViewPlansTap,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFC4A6),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4D6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 34,
              color: Color(0xFFF97316),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'You’re not enrolled in a YTT Live cohort yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E1B39),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 560,
            ),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.blueGrey,
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onViewPlansTap,
              icon: const Icon(
                Icons.workspace_premium_outlined,
                size: 20,
              ),
              label: const Text(
                'View YTT Live Plans',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFB7A34),
                foregroundColor: Colors.white,
                elevation: 3,
                minimumSize: const Size(
                  double.infinity,
                  50,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EnrolledStateSection extends StatelessWidget {
  const EnrolledStateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 54,
            color: Colors.green.shade600,
          ),
          const SizedBox(height: 14),
          Text(
            'Your YTT Live classes are ready',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E1B39),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your upcoming sessions and available recordings will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}