"use client"

import { useState, useRef } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { Play, Pause, Monitor, Volume2, VolumeX, Gauge } from "lucide-react"
import { Button } from "@/components/ui/button"

const screenshots = [
  {
    id: "dashboard",
    title: "Dashboard",
    description: "Your personalized career hub with activity tracking and job recommendations",
    image: "https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20192736-NqYT7e5iAxP21dvNWEDqpAielx96bZ.png",
  },
  {
    id: "resume",
    title: "Resume Analysis",
    description: "AI-powered resume parsing with skill extraction and professional insights",
    image: "https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20192842-WQgqQ23Gi9dnJ9PKZkUolU7U2TujdV.png",
  },
  {
    id: "interview",
    title: "AI Interview",
    description: "Practice with our AI interviewer featuring real-time feedback",
    image: "https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20193016-PowjYPqupsyxl6hZWrFDmTQ7Ezun1h.png",
  },
  {
    id: "profile",
    title: "Candidate Profile",
    description: "Complete professional profile with employability scoring",
    image: "https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20193208-KYmhXLi0SPT2vSrkXHmJ6laTxIN7Ej.png",
  },
  {
    id: "employer",
    title: "Employer Dashboard",
    description: "Powerful recruitment tools with AI-powered candidate scoring",
    image: "https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20193454-SV0KPdviuzU13l2K6xdpbwTjWjUIFb.png",
  },
]

export function DemoShowcase() {
  const [activeTab, setActiveTab] = useState("dashboard")
  const [isVideoPlaying, setIsVideoPlaying] = useState(false)
  const [isMuted, setIsMuted] = useState(true)
  const [playbackSpeed, setPlaybackSpeed] = useState(1)
  const videoRef = useRef<HTMLVideoElement>(null)
  
  const activeScreenshot = screenshots.find((s) => s.id === activeTab)

  const toggleVideo = () => {
    setIsVideoPlaying(!isVideoPlaying)
  }

  const toggleMute = () => {
    if (videoRef.current) {
      videoRef.current.muted = !isMuted
      setIsMuted(!isMuted)
    }
  }

  const cycleSpeed = () => {
    const speeds = [1, 1.5, 2, 0.5]
    const currentIndex = speeds.indexOf(playbackSpeed)
    const nextIndex = (currentIndex + 1) % speeds.length
    const newSpeed = speeds[nextIndex]
    setPlaybackSpeed(newSpeed)
    if (videoRef.current) {
      videoRef.current.playbackRate = newSpeed
    }
  }

  return (
    <section className="py-24 lg:py-32 relative overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[1000px] h-[1000px] rounded-full bg-primary/5 blur-[150px]" />
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-12"
        >
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-accent/10 border border-accent/20 mb-4">
            <Monitor className="w-4 h-4 text-accent" />
            <span className="text-sm font-medium text-accent">Platform Preview</span>
          </div>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-foreground mb-4 text-balance">
            See <span className="text-gradient">HASSLE-FREE</span> in Action
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto text-pretty">
            Explore our powerful features through interactive demos and screenshots.
          </p>
        </motion.div>

        {/* Tab Navigation */}
        <div className="flex flex-wrap justify-center gap-2 mb-8">
          {screenshots.map((screen) => (
            <button
              key={screen.id}
              onClick={() => setActiveTab(screen.id)}
              className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-300 ${
                activeTab === screen.id
                  ? "gradient-primary text-primary-foreground"
                  : "bg-muted text-muted-foreground hover:bg-muted/80"
              }`}
            >
              {screen.title}
            </button>
          ))}
        </div>

        {/* Main Display */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="relative"
        >
          {/* Browser Frame */}
          <div className="rounded-2xl border border-border bg-card overflow-hidden shadow-2xl">
            {/* Browser Header */}
            <div className="flex items-center gap-2 px-4 py-3 bg-muted/50 border-b border-border">
              <div className="flex gap-2">
                <div className="w-3 h-3 rounded-full bg-red-400" />
                <div className="w-3 h-3 rounded-full bg-yellow-400" />
                <div className="w-3 h-3 rounded-full bg-green-400" />
              </div>
              <div className="flex-1 mx-4">
                <div className="bg-background rounded-md px-4 py-1.5 text-sm text-muted-foreground flex items-center gap-2 max-w-md mx-auto">
                  <Monitor className="w-4 h-4" />
                  <span>hassle-free.pk/{activeTab}</span>
                </div>
              </div>
            </div>

            {/* Content */}
            <AnimatePresence mode="wait">
              <motion.div
                key={activeTab}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                transition={{ duration: 0.3 }}
                className="relative"
              >
                <img
                  src={activeScreenshot?.image}
                  alt={activeScreenshot?.title}
                  className="w-full h-auto"
                />
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Description Card */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="absolute -bottom-6 right-4 lg:right-8 bg-card rounded-xl p-4 shadow-xl border border-border max-w-xs hidden md:block"
          >
            <h4 className="font-semibold text-foreground mb-1">{activeScreenshot?.title}</h4>
            <p className="text-sm text-muted-foreground">{activeScreenshot?.description}</p>
          </motion.div>
        </motion.div>

        {/* Video Demo Button */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5, delay: 0.4 }}
          className="mt-12 flex flex-wrap justify-center gap-3"
        >
          <Button
            size="lg"
            variant="outline"
            className="group"
            onClick={toggleVideo}
          >
            {isVideoPlaying ? (
              <>
                <Pause className="mr-2 w-4 h-4" />
                Pause Video
              </>
            ) : (
              <>
                <Play className="mr-2 w-4 h-4 group-hover:scale-110 transition-transform" />
                Watch Full Demo Video
              </>
            )}
          </Button>
          
          {isVideoPlaying && (
            <>
              <Button
                size="lg"
                variant="outline"
                onClick={cycleSpeed}
                className="gap-2"
              >
                <Gauge className="w-4 h-4" />
                {playbackSpeed}x Speed
              </Button>
              
              <Button
                size="lg"
                variant="outline"
                onClick={toggleMute}
                className="gap-2"
              >
                {isMuted ? (
                  <>
                    <VolumeX className="w-4 h-4" />
                    Unmute
                  </>
                ) : (
                  <>
                    <Volume2 className="w-4 h-4" />
                    Mute
                  </>
                )}
              </Button>
            </>
          )}
        </motion.div>

        {/* Video Modal */}
        <AnimatePresence>
          {isVideoPlaying && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="mt-8 rounded-2xl overflow-hidden shadow-2xl border border-border"
            >
              <video
                ref={videoRef}
                autoPlay
                muted={isMuted}
                loop
                playsInline
                className="w-full h-auto"
                src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/fyp11_JggvcePp-IS3QtvzS2hDLhrk6Tgaz6xG4PtZ88U.mp4"
              >
                Your browser does not support the video tag.
              </video>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </section>
  )
}
