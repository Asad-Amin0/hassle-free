"use client"

import { motion } from "framer-motion"
import { FileText, Brain, Video, Target, Award, Users, Zap, TrendingUp } from "lucide-react"
import { SkillsWidget } from "./skills-widget"

const features = [
  {
    icon: FileText,
    title: "AI Resume Parsing",
    description: "Advanced NLP technology extracts skills, experience, and qualifications from your resume automatically.",
    gradient: "from-primary to-primary/70",
    delay: 0,
  },
  {
    icon: Brain,
    title: "Smart Job Matching",
    description: "Our ML algorithms match you with roles that perfectly align with your skills and career goals.",
    gradient: "from-secondary to-secondary/70",
    delay: 0.1,
  },
  {
    icon: Video,
    title: "AI Mock Interviews",
    description: "Practice with our AI interviewer that provides real-time feedback on content, delivery, and confidence.",
    gradient: "from-accent to-accent/70",
    delay: 0.2,
  },
  {
    icon: Award,
    title: "Employability Scoring",
    description: "Get a comprehensive score based on your profile with actionable insights to improve.",
    gradient: "from-primary to-secondary",
    delay: 0.3,
  },
  {
    icon: Target,
    title: "Skill Assessment",
    description: "Identify skill gaps and receive personalized recommendations for career development.",
    gradient: "from-secondary to-accent",
    delay: 0.4,
  },
  {
    icon: Users,
    title: "Employer Dashboard",
    description: "Companies get powerful tools for bias-free candidate evaluation and smart shortlisting.",
    gradient: "from-accent to-primary",
    delay: 0.5,
  },
]

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
}

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.5,
    },
  },
}

export function FeaturesSection() {
  return (
    <section id="features" className="py-24 lg:py-32 relative overflow-hidden">
      {/* Background decorations */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 -right-48 w-96 h-96 rounded-full bg-primary/5 blur-3xl" />
        <div className="absolute bottom-1/4 -left-48 w-96 h-96 rounded-full bg-secondary/5 blur-3xl" />
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary/10 border border-primary/20 mb-4">
            <Zap className="w-4 h-4 text-primary" />
            <span className="text-sm font-medium text-primary">Powerful Features</span>
          </div>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-foreground mb-4 text-balance">
            Everything You Need to
            <span className="text-gradient"> Land Your Dream Job</span>
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto text-pretty">
            Our AI-powered platform provides comprehensive tools for job seekers and employers
            to streamline the entire recruitment process.
          </p>
        </motion.div>

        {/* Features Grid */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8"
        >
          {features.map((feature, index) => (
            <motion.div
              key={feature.title}
              variants={itemVariants}
              className="group relative"
            >
              <div className="h-full p-6 lg:p-8 rounded-2xl bg-card border border-border hover:border-primary/50 transition-all duration-300 hover:shadow-lg hover:shadow-primary/5">
                {/* Icon */}
                <div className={`w-14 h-14 rounded-xl bg-gradient-to-br ${feature.gradient} flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300`}>
                  <feature.icon className="w-7 h-7 text-primary-foreground" />
                </div>

                {/* Content */}
                <h3 className="text-xl font-semibold text-foreground mb-3">
                  {feature.title}
                </h3>
                <p className="text-muted-foreground leading-relaxed">
                  {feature.description}
                </p>

                {/* Hover Indicator */}
                <div className="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-primary to-secondary rounded-b-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              </div>
            </motion.div>
          ))}
        </motion.div>

        {/* Skills Widget */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="mt-16 p-8 rounded-2xl bg-card border border-border"
        >
          <h3 className="text-2xl font-bold text-foreground text-center mb-6">
            Skills We Detect & Badges You Can Earn
          </h3>
          <SkillsWidget />
        </motion.div>

        {/* Bottom Stats Bar */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="mt-12 p-8 rounded-2xl gradient-primary"
        >
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-8">
            <div className="text-center">
              <TrendingUp className="w-8 h-8 text-primary-foreground mx-auto mb-2" />
              <div className="text-3xl lg:text-4xl font-bold text-primary-foreground mb-1">40%</div>
              <div className="text-sm text-primary-foreground/80">Faster Hiring</div>
            </div>
            <div className="text-center">
              <Award className="w-8 h-8 text-primary-foreground mx-auto mb-2" />
              <div className="text-3xl lg:text-4xl font-bold text-primary-foreground mb-1">90%</div>
              <div className="text-sm text-primary-foreground/80">Accuracy Rate</div>
            </div>
            <div className="text-center">
              <Users className="w-8 h-8 text-primary-foreground mx-auto mb-2" />
              <div className="text-3xl lg:text-4xl font-bold text-primary-foreground mb-1">10K+</div>
              <div className="text-sm text-primary-foreground/80">Job Seekers</div>
            </div>
            <div className="text-center">
              <Target className="w-8 h-8 text-primary-foreground mx-auto mb-2" />
              <div className="text-3xl lg:text-4xl font-bold text-primary-foreground mb-1">500+</div>
              <div className="text-sm text-primary-foreground/80">Partner Companies</div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  )
}
