"use client"

import { motion } from "framer-motion"
import { Upload, Search, Video, CheckCircle, ArrowRight } from "lucide-react"

const steps = [
  {
    number: "01",
    icon: Upload,
    title: "Upload Your Resume",
    description: "Simply upload your resume and our AI will automatically parse and analyze your professional profile.",
    image: "https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20192842-WQgqQ23Gi9dnJ9PKZkUolU7U2TujdV.png",
  },
  {
    number: "02",
    icon: Search,
    title: "Get Matched with Jobs",
    description: "Our intelligent matching system finds the best opportunities based on your skills and preferences.",
    image: "https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20192736-NqYT7e5iAxP21dvNWEDqpAielx96bZ.png",
  },
  {
    number: "03",
    icon: Video,
    title: "Practice Interviews",
    description: "Prepare with AI-powered mock interviews that provide real-time feedback and improvement tips.",
    image: "https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20193016-PowjYPqupsyxl6hZWrFDmTQ7Ezun1h.png",
  },
  {
    number: "04",
    icon: CheckCircle,
    title: "Land Your Dream Job",
    description: "Apply confidently with your improved profile and get hired by top companies.",
    image: "https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20193208-KYmhXLi0SPT2vSrkXHmJ6laTxIN7Ej.png",
  },
]

export function HowItWorksSection() {
  return (
    <section id="how-it-works" className="py-24 lg:py-32 bg-muted/30 relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-30">
        <div className="absolute inset-0" style={{
          backgroundImage: `radial-gradient(circle at 1px 1px, currentColor 1px, transparent 0)`,
          backgroundSize: '40px 40px',
          opacity: 0.1,
        }} />
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
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-foreground mb-4 text-balance">
            How It <span className="text-gradient">Works</span>
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto text-pretty">
            Get started in minutes with our simple 4-step process to transform your job search experience.
          </p>
        </motion.div>

        {/* Steps */}
        <div className="space-y-24">
          {steps.map((step, index) => (
            <motion.div
              key={step.number}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-100px" }}
              transition={{ duration: 0.6, delay: index * 0.1 }}
              className={`flex flex-col ${
                index % 2 === 0 ? "lg:flex-row" : "lg:flex-row-reverse"
              } items-center gap-8 lg:gap-16`}
            >
              {/* Content */}
              <div className="flex-1 text-center lg:text-left">
                <div className="inline-flex items-center gap-3 mb-4">
                  <span className="text-5xl font-bold text-primary/20">{step.number}</span>
                  <div className="w-12 h-12 rounded-xl gradient-primary flex items-center justify-center">
                    <step.icon className="w-6 h-6 text-primary-foreground" />
                  </div>
                </div>
                <h3 className="text-2xl lg:text-3xl font-bold text-foreground mb-4">
                  {step.title}
                </h3>
                <p className="text-lg text-muted-foreground max-w-md mx-auto lg:mx-0">
                  {step.description}
                </p>
                
                {index < steps.length - 1 && (
                  <div className="hidden lg:flex items-center gap-2 mt-6 text-primary">
                    <span className="text-sm font-medium">Next Step</span>
                    <ArrowRight className="w-4 h-4" />
                  </div>
                )}
              </div>

              {/* Image */}
              <div className="flex-1 w-full max-w-xl">
                <motion.div
                  whileHover={{ scale: 1.02 }}
                  transition={{ duration: 0.3 }}
                  className="relative rounded-2xl overflow-hidden shadow-2xl border border-border"
                >
                  <img
                    src={step.image}
                    alt={step.title}
                    className="w-full h-auto"
                  />
                  {/* Overlay Gradient */}
                  <div className="absolute inset-0 bg-gradient-to-t from-foreground/10 to-transparent opacity-0 hover:opacity-100 transition-opacity duration-300" />
                </motion.div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
