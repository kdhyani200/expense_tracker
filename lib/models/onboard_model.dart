class Onboard {
  final String image, title, description;

  Onboard({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<Onboard> demoData = [
  Onboard(
    image: "assets/png1.png",
    title: "Find Internships\nThat Matter",
    description:
        "Explore curated internships and entry-level jobs tailored for freshers like you.",
  ),
  Onboard(
    image: "assets/png2.png",
    title: "Get Referrals\nFaster",
    description:
        "Connect with developers and discover referral opportunities to boost your chances.",
  ),
  Onboard(
    image: "assets/png3.png",
    title: "Track Your\nApplications",
    description:
        "Save jobs and track your application status all in one place.",
  ),
  Onboard(
    image: "assets/png4.png",
    title: "Build Your\nProfile",
    description:
        "Showcase your skills, projects, and resume to stand out to recruiters.",
  ),
  Onboard(
    image: "assets/png5.png",
    title: "Start Your Career\nJourney",
    description: "Take the first step towards your dream job with FresherHub.",
  ),
];
