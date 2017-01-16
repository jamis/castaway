soundclip :theme do |clip|
  clip.in resource('theme.mp3')
  clip.chain.
    trim(0, 15).
    fade(0.5, 0, 5, type: :linear)
  clip.chain.
    trim(0, 30).
    fade(5, 0, 5, type: :linear).
    pad(120)
end
