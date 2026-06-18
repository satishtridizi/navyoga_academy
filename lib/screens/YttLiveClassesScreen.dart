import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/LiveClassData.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';

class YttLiveClassesScreen extends StatelessWidget {
  const YttLiveClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = LiveClassData(
      enrolled: false,
      title: "My YTT Live Classes",
      description:
          "Live yoga teacher training sessions and recordings from your enrolled cohorts",
    );

    return Scaffold(
      drawer: const CustomDrawer(currentPage: "YTT Live Classes"),
      //currentIndex: null,
      appBar: AppBar(
        leadingWidth: 72,
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xff1E1B39)),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),

        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 60,
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              HeaderSection(
                data: data,
                onEnrollTap: () {
                  Navigator.pushNamed(context, AppRoutes.payments);
                },
              ),

              const SizedBox(height: 15),

              EmptyStateSection(
                description:
                    "Enroll in a YTT Live course from the plans page to access its live sessions and recordings.",
                onViewPlansTap: () {
                  Navigator.pushNamed(context, AppRoutes.payments);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xfff97316), Color(0xff6a0dad)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool mobile = constraints.maxWidth < 700;

          return mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleContent(),
                    const SizedBox(height: 20),
                    _statusCard(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _titleContent()),
                    const SizedBox(width: 20),
                    _statusCard(),
                  ],
                );
        },
      ),
    );
  }

  Widget _titleContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.school_outlined, color: Colors.white, size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          data.description,
          style: GoogleFonts.poppins(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _statusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.lock_outline),
              const SizedBox(width: 8),
              Text(
                data.enrolled ? "Enrolled" : "Not enrolled",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onEnrollTap,
            icon: const Icon(Icons.workspace_premium_outlined),
            label: const Text("Enroll"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfffb7a34),
              foregroundColor: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
    return InkWell(
      onTap: () {
        debugPrint("Container Clicked");
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xfff7eef0),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xffffb48e)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xffffe4d6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 32,
                color: Color(0xfff97316),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "You're not enrolled in any YTT Live cohort yet",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                textStyle: TextStyle(
                  color: Color.fromARGB(255, 130, 130, 130),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: onViewPlansTap,
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text("View YTT Live Plans"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfffb7a34),
                foregroundColor: Colors.white,
                elevation: 5,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
