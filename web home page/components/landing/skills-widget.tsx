"use client"

import { motion } from "framer-motion"

const skills = [
  { name: "Android Studio", color: "bg-green-500" },
  { name: "C++", color: "bg-blue-500" },
  { name: "Dart", color: "bg-cyan-500" },
  { name: "Excel", color: "bg-emerald-500" },
  { name: "Firebase", color: "bg-amber-500" },
  { name: "Go", color: "bg-sky-500" },
  { name: "Java", color: "bg-red-500" },
  { name: "MySQL", color: "bg-orange-500" },
  { name: "Python", color: "bg-yellow-500" },
  { name: "SQL", color: "bg-indigo-500" },
  { name: "SQLite", color: "bg-purple-500" },
  { name: "React", color: "bg-cyan-400" },
  { name: "Node.js", color: "bg-green-600" },
  { name: "TypeScript", color: "bg-blue-600" },
  { name: "Flutter", color: "bg-blue-400" },
]

const badges = [
  { name: "Top Skilled", icon: "🏆", description: "Employability 85%+" },
  { name: "Technical Specialist", icon: "💻", description: "High technical proficiency" },
  { name: "Highly Employable", icon: "✅", description: "Ready for interviews" },
  { name: "Rising Star", icon: "⭐", description: "Showing great potential" },
]

export function SkillsWidget() {
  return (
    <div className="space-y-8">
      {/* Skills Cloud */}
      <div className="flex flex-wrap gap-3 justify-center">
        {skills.map((skill, index) => (
          <motion.div
            key={skill.name}
            initial={{ opacity: 0, scale: 0 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.3, delay: index * 0.05 }}
            whileHover={{ scale: 1.1 }}
            className={`${skill.color} px-4 py-2 rounded-full text-white text-sm font-medium shadow-lg cursor-default`}
          >
            {skill.name}
          </motion.div>
        ))}
      </div>

      {/* Badges */}
      <div className="flex flex-wrap gap-4 justify-center">
        {badges.map((badge, index) => (
          <motion.div
            key={badge.name}
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.4, delay: 0.3 + index * 0.1 }}
            whileHover={{ y: -5 }}
            className="bg-card border border-border rounded-xl p-4 text-center min-w-[140px] shadow-sm hover:shadow-md transition-shadow"
          >
            <div className="text-3xl mb-2">{badge.icon}</div>
            <div className="font-semibold text-foreground text-sm">{badge.name}</div>
            <div className="text-xs text-muted-foreground mt-1">{badge.description}</div>
          </motion.div>
        ))}
      </div>
    </div>
  )
}
