soundtrack do |clip|
  combined = duck(
    soundclip(:theme),
    clip: soundclip(:narration), at: 3, adjust: 0.25)

  clip.in combined
end
