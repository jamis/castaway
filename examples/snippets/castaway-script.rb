# castaway-script.rb

soundclip :theme, resource('theme-music.mp3')
soundclip :narration, resource('narration.aiff')

soundtrack do |clip|
  result = duck(
    soundclip(:theme),
    clip: soundclip(:narration), at: 3, adjust: 0.25)
  clip.in result
end

scene 'Title' do
  start '0:00'

  plan do
    still 'title.png'
  end
end
