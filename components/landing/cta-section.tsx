"use client"

import { motion } from "framer-motion"
import { Button } from "@/components/ui/button"
import { ArrowRight, Sparkles, Rocket } from "lucide-react"

const APP_URL = "https://hassle-free-app.vercel.app"

export function CTASection() {
  return (
    <section className="py-24 lg:py-32 relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="relative rounded-3xl overflow-hidden"
        >
          {/* Background Gradient */}
          <div className="absolute inset-0 gradient-hero animate-gradient" />
          
          {/* Decorative Elements */}
          <div className="absolute top-0 right-0 w-96 h-96 bg-white/10 rounded-full blur-3xl" />
          <div className="absolute bottom-0 left-0 w-64 h-64 bg-white/10 rounded-full blur-2xl" />
          
          {/* Floating Icons */}
          <motion.div
            animate={{ y: [-10, 10, -10], rotate: [0, 5, 0] }}
            transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
            className="absolute top-10 left-10 w-16 h-16 rounded-2xl bg-white/20 backdrop-blur flex items-center justify-center"
          >
            <Sparkles className="w-8 h-8 text-white" />
          </motion.div>
          
          <motion.div
            animate={{ y: [10, -10, 10], rotate: [0, -5, 0] }}
            transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
            className="absolute bottom-10 right-10 w-14 h-14 rounded-xl bg-white/20 backdrop-blur flex items-center justify-center"
          >
            <Rocket className="w-7 h-7 text-white" />
          </motion.div>

          {/* Content */}
          <div className="relative z-10 px-8 py-16 lg:px-16 lg:py-24 text-center">
            <motion.h2
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="text-3xl sm:text-4xl lg:text-5xl xl:text-6xl font-bold text-white mb-6 text-balance"
            >
              Ready to Transform
              <br />
              Your Career Journey?
            </motion.h2>

            <motion.p
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.3 }}
              className="text-lg lg:text-xl text-white/80 max-w-2xl mx-auto mb-10 text-pretty"
            >
              Join thousands of job seekers and employers who are already experiencing 
              the future of recruitment. Start your hassle-free journey today.
            </motion.p>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.4 }}
              className="flex flex-col sm:flex-row gap-4 justify-center"
            >
              <Button 
                size="lg" 
                className="bg-white text-primary hover:bg-white/90 group"
                asChild
              >
                <a href={APP_URL} target="_blank" rel="noopener noreferrer">
                  Get Started Free
                  <ArrowRight className="ml-2 w-4 h-4 group-hover:translate-x-1 transition-transform" />
                </a>
              </Button>
              <Button 
                size="lg" 
                variant="outline"
                className="border-2 border-white bg-transparent text-white hover:bg-white hover:text-primary font-semibold"
                asChild
              >
                <a href={APP_URL} target="_blank" rel="noopener noreferrer">Schedule a Demo</a>
              </Button>
            </motion.div>

            {/* Trust Badge */}
            <motion.div
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.5 }}
              className="mt-10 flex items-center justify-center gap-2 text-white/60 text-sm"
            >
              <span>No credit card required</span>
              <span className="w-1 h-1 rounded-full bg-white/40" />
              <span>Free forever plan</span>
              <span className="w-1 h-1 rounded-full bg-white/40" />
              <span>Setup in 2 minutes</span>
            </motion.div>
          </div>
        </motion.div>
      </div>
    </section>
  )
}
