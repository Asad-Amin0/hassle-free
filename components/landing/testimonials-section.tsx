"use client"

import { motion } from "framer-motion"
import { Star, Quote } from "lucide-react"

const testimonials = [
  {
    name: "Waleed Tariq",
    role: "Software Developer",
    company: "Devsinc",
    avatar: "W",
    rating: 5,
    text: "HASSLE-FREE completely transformed my job search. The AI resume analysis helped me identify gaps I never knew existed, and the mock interviews boosted my confidence significantly.",
    gradient: "from-primary to-secondary",
  },
  {
    name: "Sarah Ahmed",
    role: "HR Manager",
    company: "TechCorp Pakistan",
    avatar: "S",
    rating: 5,
    text: "As a recruiter, this platform has cut our hiring time in half. The AI scoring system is incredibly accurate and helps us focus on the best candidates immediately.",
    gradient: "from-secondary to-accent",
  },
  {
    name: "Hassan Ali",
    role: "Fresh Graduate",
    company: "UCP Lahore",
    avatar: "H",
    rating: 5,
    text: "Being a fresh graduate was tough, but HASSLE-FREE&apos;s employability score gave me a clear roadmap. I landed my first job within a month of using the platform!",
    gradient: "from-accent to-primary",
  },
]

export function TestimonialsSection() {
  return (
    <section id="testimonials" className="py-24 lg:py-32 bg-muted/30 relative overflow-hidden">
      {/* Background Decorations */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <Quote className="absolute top-20 left-10 w-32 h-32 text-primary/5" />
        <Quote className="absolute bottom-20 right-10 w-48 h-48 text-secondary/5 rotate-180" />
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
            Loved by <span className="text-gradient">Thousands</span>
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto text-pretty">
            See what our users are saying about their experience with HASSLE-FREE.
          </p>
        </motion.div>

        {/* Testimonials Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8">
          {testimonials.map((testimonial, index) => (
            <motion.div
              key={testimonial.name}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              className="group"
            >
              <div className="h-full p-6 lg:p-8 rounded-2xl bg-card border border-border hover:border-primary/30 transition-all duration-300 hover:shadow-lg">
                {/* Rating */}
                <div className="flex gap-1 mb-4">
                  {[...Array(testimonial.rating)].map((_, i) => (
                    <Star key={i} className="w-5 h-5 fill-yellow-400 text-yellow-400" />
                  ))}
                </div>

                {/* Quote */}
                <p className="text-foreground mb-6 leading-relaxed">
                  &ldquo;{testimonial.text}&rdquo;
                </p>

                {/* Author */}
                <div className="flex items-center gap-4">
                  <div className={`w-12 h-12 rounded-full bg-gradient-to-br ${testimonial.gradient} flex items-center justify-center text-primary-foreground font-semibold`}>
                    {testimonial.avatar}
                  </div>
                  <div>
                    <div className="font-semibold text-foreground">{testimonial.name}</div>
                    <div className="text-sm text-muted-foreground">
                      {testimonial.role} at {testimonial.company}
                    </div>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Trust Indicators */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="mt-16 text-center"
        >
          <p className="text-sm text-muted-foreground mb-6">Trusted by leading organizations</p>
          <div className="flex flex-wrap justify-center items-center gap-8 lg:gap-16 opacity-60">
            {["University of Central Punjab", "Devsinc", "Systems Limited", "TechCorp", "i2c Inc"].map((company) => (
              <div key={company} className="text-lg font-semibold text-muted-foreground">
                {company}
              </div>
            ))}
          </div>
        </motion.div>
      </div>
    </section>
  )
}
