# A practical tutorial screencast, introducing Castaway and demonstrating
# what it can do.

voice_in = 3 # narration track starts 3 seconds in

pointer 'arrow.png', hotspot: [152, 12], scale: 0.1

soundclip :narration, resource('narration.mp3')

soundclip :theme do |clip|
  intro_duration = scene('Title Screen').duration
  outro_duration = scene('Fade to Black').duration +
                   scene('Credits').duration + 5
  padding = duration - intro_duration - outro_duration

  clip.in resource('Lee_Rosevere_-_09_-_Biking_in_the_Park.mp3')
  clip.chain.
    trim(0, intro_duration).
    fade(0.5, 0, 6, type: :linear)
  clip.chain.
    trim(0, outro_duration).
    fade(5, 0, 5, type: :linear).
    pad(padding)
end

soundtrack do |clip|
  mixed = duck(soundclip(:theme),
               clip: soundclip(:narration), at: voice_in, adjust: 0.2)
  clip.in mixed
end

scene 'Title Screen' do
  start '0:00'
  script <<-SCRIPT
    Hello, and thanks for checking out Castaway! I'm Jamis Buck, Castaway's
    author, and in this video we'll be looking at some of what Castaway can
    do.
  SCRIPT

  plan do
    matte(:black).exit(1)
    still('castaway-logo.png').enter(0.5).in(:dissolve, speed: 0.5)
  end
end

scene 'Castaway Script' do
  start voice_in + time('0:09.5')

  script <<-SCRIPT
    A Castaway script is just a Ruby program. In it, you declare sound clips
    that are composed into a sound track, as well as scenes that are each
    composed of different elements.
  SCRIPT

  relative    = relative_to_image 'castaway-script.png'
  arrow_start = time('0:11.0')

  #                age of arrow                  position of arrow
  ruby_program = [ 0,                            relative.position(686, 104) ]
  sound_clips  = [ time('0:13.7') - arrow_start, relative.position(1120, 177) ]
  soundtrack   = [ time('0:15.7') - arrow_start, relative.position(700, 285) ]
  scenes       = [ time('0:17.2') - arrow_start, relative.position(633, 550) ]
  elements     = [ time('0:19.5') - arrow_start, relative.position(710, 686) ]

  plan do
    still('castaway-script.png').enter(-0.5).in(:dissolve, speed: 0.5)

    pointer.
      rotate(150).
      enter(voice_in + arrow_start - start).
      in(:dissolve, speed: 0.25).
      path(ruby_program[0]       => ruby_program[1],
           sound_clips[0] - 0.25 => ruby_program[1],
           sound_clips[0]        => sound_clips[1],
           soundtrack[0] - 0.25  => sound_clips[1],
           soundtrack[0]         => soundtrack[1],
           scenes[0] - 0.25      => soundtrack[1],
           scenes[0]             => scenes[1],
           elements[0] - 0.25    => scenes[1],
           elements[0]           => elements[1])
  end
end

scene 'Still Image' do
  start voice_in + time('0:20.9')

  script <<-SCRIPT
    The simplest kind of element is a still image, or slide, like our title
    screen. The title screen was a bit fancy, though, because it faded-in from
    black.
  SCRIPT

  plan do
    still('still-image.png').enter(-0.5).in(:dissolve, speed: 0.5)
  end
end

scene 'Fade In - Step 1' do
  start voice_in + time('0:31.1')

  script <<-SCRIPT
    We did this by first creating a matte black still frame,
  SCRIPT

  plan do
    still('fade-in-step-1.png').enter(-0.5).in(:dissolve, speed: 0.5)
  end
end

scene 'Fade In - Step 2' do
  start voice_in + time('0:35.3')

  script <<-SCRIPT
    and then having our title screen dissolve in over it.
  SCRIPT

  plan do
    still('fade-in-step-2.png').enter(-0.5).in(:dissolve, speed: 0.5)
  end
end

scene 'Dissolve In' do
  start voice_in + time('0:39.5')

  script <<-SCRIPT
    If you want another scene to dissolve in over a previous scene, that's easy,
    too. Just have the first element of the new scene enter a half second
    early, and then dissolve in. Piece of cake!
  SCRIPT

  relative     = relative_to_image 'dissolve-in.png'
  arrow_start  = time('0:44.8')
  arrow_finish = time('0:49.5')

  #                age of arrow                  position of arrow
  first_elem  = [ 0,                            relative.position(990, 390) ]
  enter_cmd   = [ time('0:46.3') - arrow_start, relative.position(830, 435) ]
  dissolve_in = [ time('0:48.5') - arrow_start, relative.position(1050, 465) ]

  plan do
    still('dissolve-in.png').enter(-0.5).in(:dissolve, speed: 0.5)

    pointer.
      rotate(150).
      enter(voice_in + arrow_start - start).
      exit(voice_in + arrow_finish - start).
      in(:dissolve, speed: 0.25).
      out(:dissolve, speed: 0.25).
      path(first_elem[0]         => first_elem[1],
           enter_cmd[0] - 0.25   => first_elem[1],
           enter_cmd[0]          => enter_cmd[1],
           dissolve_in[0] - 0.25 => enter_cmd[1],
           dissolve_in[0]        => dissolve_in[1])
  end
end

scene 'Pointer' do
  start voice_in + time('0:51.2')

  script <<-SCRIPT
    Sometimes you want to highlight something in your presentation by pointing
    an arrow at it. This is easy to do in Castaway, too.
  SCRIPT

  plan do
    still('pointer-slide.png').enter(-0.5).in(:dissolve, speed: 0.5)

    pointer.
      at(relative_to_image('pointer-slide.png').position(923, 337)).
      rotate(145).
      scale(0.75).
      enter(voice_in + time('0:54.18') - start).
      exit(voice_in + time('0:55.26') - start).
      in(:dissolve, speed: 0.25).
      out(:dissolve, speed: 0.25)
  end
end

scene 'Prepare Arrow' do
  start voice_in + time('0:58.6')
  script <<-SCRIPT
    First, prepare an image that you want to be your arrow. Any image will do.
    Any size, any color, any orientation. Just note the coordinates of the
    "hot spot", or the position of the pointer.
  SCRIPT

  hot_spot = voice_in + time('1:07.75') - start

  plan do
    matte(:white).enter(-0.5).in(:dissolve, speed: 0.5)
    arrow = sprite('arrow.png').
            gravity(:center).enter(0.5).in(:dissolve, speed: 0.5)

    rel = relative_to_image('arrow.png')
    pos = arrow.position + Point.new(152, 12)

    pointer.
      rotate(150).
      at(pos).
      enter(hot_spot).
      exit(hot_spot + 2).
      in(:dissolve, speed: 0.25).
      out(:dissolve, speed: 0.25)
  end
end

scene 'Declare Pointer' do
  start voice_in + time('1:10.7')

  script <<-SCRIPT
    Then, in your script, declare your pointer. Be sure and tell it the location
    of the hotspot, and the size of the arrow. This size is relative to the
    size of the frame, so here we're saying we want the arrow to be 10% of the
    frame size.
  SCRIPT

  relative    = relative_to_image 'declare-pointer.png'
  arrow_start = time('1:14.4')
  arrow_end   = time('1:18')

  hotspot  = [ 0,                            relative.position(1029, 347) ]
  relsize  = [ time('1:16.4') - arrow_start, relative.position(1234, 347) ]

  plan do
    still('declare-pointer.png').enter(-0.5).in(:dissolve, speed: 0.5)

    pointer.
      rotate(150).
      enter(voice_in + arrow_start - start).
      exit(voice_in + arrow_end - start).
      in(:dissolve, speed: 0.25).
      out(:dissolve, speed: 0.25).
      path(hotspot[0]        => hotspot[1],
           relsize[0] - 0.25 => hotspot[1],
           relsize[0]        => relsize[1])
  end
end

scene 'Add Pointer' do
  start voice_in + time('1:25.8')
  script <<-SCRIPT
    Lastly, in any scene where we want a pointer, we add a pointer element,
    tell it where it should be, and how it should be rotated.
  SCRIPT

  relative    = relative_to_image('add-pointer.png')
  arrow_start = time('1:29.3')

  addptr    = [0,                            relative.position(649, 437)]
  ptrwhere  = [time('1:30.6') - arrow_start, relative.position(1067, 463)]
  ptrrotate = [time('1:32.1') - arrow_start, relative.position(737, 511)]

  plan do
    still('add-pointer.png').enter(-0.5).in(:dissolve, speed: 0.5)

    pointer.
      rotate(150).
      enter(voice_in + arrow_start - start).
      in(:dissolve, speed: 0.25).
      path(addptr[0]           => addptr[1],
           ptrwhere[0] - 0.25  => addptr[1],
           ptrwhere[0]         => ptrwhere[1],
           ptrrotate[0] - 0.25 => ptrwhere[1],
           ptrrotate[0]        => ptrrotate[1])
  end
end

scene 'Dissolve Pointer' do
  start voice_in + time('1:34.1')
  script <<-SCRIPT
    We can even dissolve the arrows in and out, just like still frames!
  SCRIPT

  plan do
    still('dissolve-pointer.png').enter(-0.5).in(:dissolve, speed: 0.5)
  end
end

scene 'Move Pointer' do
  start voice_in + time('1:38.8')
  script <<-SCRIPT
    Sometimes we want the arrows to move around. Maybe we want to highlight
    different parts of the frame, like this.
  SCRIPT

  arrow_start = time('1:41.4')
  arrow_end   = time('1:46.25')
  segment     = (arrow_end - arrow_start) / 8

  nw = [0,           relative_position(0.25, 0.25)]
  ne = [segment * 2, relative_position(0.75, 0.25)]
  se = [segment * 4, relative_position(0.75, 0.75)]
  sw = [segment * 6, relative_position(0.25, 0.75)]

  plan do
    matte(:white).enter(-0.5).in(:dissolve, speed: 0.5)

    pointer.
      rotate(150).
      enter(voice_in + arrow_start - start).
      in(:dissolve, speed: 0.25).
      path(nw[0]           => nw[1],
           ne[0] - segment => nw[1],
           ne[0]           => ne[1],
           se[0] - segment => ne[1],
           se[0]           => se[1],
           sw[0] - segment => se[1],
           sw[0]           => sw[1])
  end
end

scene 'Path Command' do
  start voice_in + time('1:46.4')
  script <<-SCRIPT
    Easy enough! We just use the "path" command and tell the arrow where we
    want it to be at each time point. The times are all relative to the moment
    the arrow enters the scene.

    Notice, too, that we're using relative positions--fractions of the frame
    size--so that we can render our movie at any resolution.
  SCRIPT

  arrow_start = time('1:57.1')

  plan do
    still('path-command.png').enter(-0.5).in(:dissolve, speed: 0.5)

    pointer.
      rotate(150).
      enter(voice_in + arrow_start - start).
      at(relative_to_image('path-command.png').position(1120, 390)).
      in(:dissolve, speed: 0.25)
  end
end

scene 'Text' do
  start voice_in + time('2:05.5')
  script <<-SCRIPT
    Okay, so what about text? You can display text overlayed on your frame with
    the "text" command. Notice that we're using a matte still frame as the
    background, here, which lets us treat the text as a slide of its own.
  SCRIPT

  plan do
    still('text.png').enter(-0.5).in(:dissolve, speed: 0.5)
  end
end

scene 'Text Demo' do
  start voice_in + time('2:19')
  script <<-SCRIPT
    Just like that!
  SCRIPT

  plan do
    matte(:white).enter(-0.5).in(:dissolve, speed: 0.5)

    text('Hello, World!').
      font('GeorgiaB').
      font_size(140 * production.resolution.width / 1600).
      gravity('Center').
      enter(-0.5).
      in(:dissolve, speed: 0.5)
  end
end

scene 'Sound - Simple' do
  start voice_in + time('2:21.1')
  script <<-SCRIPT
    What about sound, though? Easy enough. Castaway integrates with the
    Chaussettes library, for working with the sox utility. We can declare
    sound clips in our script, either as simple audio files, like this...
  SCRIPT

  plan do
    still('sound-simple.png').enter(-0.5).in(:dissolve, speed: 0.5)
  end
end

scene 'Sound - Modify' do
  start voice_in + time('2:36.5')
  script <<-SCRIPT
    Or we can have a clip be the product of some audio manipulation. Here,
    we're fading a clip in, then out after 15 seconds. Then, fading it back
    in, and then out again, and padding the middle with silence. This becomes
    our "theme music" track--fading in, then out as the narration starts, and
    then fading back in at the end.
  SCRIPT

  relative = relative_to_image('sound-modify.png')
  arrow_start = time('2:41')
  arrow_end   = time('2:50')

  fadein1  = [0,                            relative.position(722, 409)]
  fadeout1 = [time('2:43.0') - arrow_start, relative.position(827, 409)]
  fadein2  = [time('2:45.7') - arrow_start, relative.position(689, 530)]
  fadeout2 = [time('2:47.4') - arrow_start, relative.position(788, 530)]
  padmid   = [time('2:48.5') - arrow_start, relative.position(704, 564)]

  plan do
    still('sound-modify.png').enter(-0.5).in(:dissolve, speed: 0.5)

    pointer.
      rotate(150).
      enter(voice_in + arrow_start - start).
      exit(voice_in + arrow_end - start).
      in(:dissolve, speed: 0.25).
      out(:dissolve, speed: 0.25).
      path(fadein1[0]         => fadein1[1],
           fadeout1[0] - 0.25 => fadein1[1],
           fadeout1[0]        => fadeout1[1],
           fadein2[0] - 0.25  => fadeout1[1],
           fadein2[0]         => fadein2[1],
           fadeout2[0] - 0.25 => fadein2[1],
           fadeout2[0]        => fadeout2[1],
           padmid[0] - 0.25   => fadeout2[1],
           padmid[0]          => padmid[1])
  end
end

scene 'Soundtrack' do
  start voice_in + time('2:58.4')
  script <<-SCRIPT
    Those clips are then fed into the "soundtrack" command, which is used to
    combine and mix the clips into a single output. Here, we mix our narration
    track and our theme music track, making the music "duck" (or reduce in
    volume) when the narration track starts.
  SCRIPT

  plan do
    still('soundtrack.png').enter(-0.5).in(:dissolve, speed: 0.5)
  end
end

scene 'Intro Credits' do
  start voice_in + time('3:15.2')
  script <<-SCRIPT
    Finally, when our movie finishes, we'd like to scroll some credits. This
    is straightforward, too.
  SCRIPT

  plan do
    matte(:white).enter(-0.5).in(:dissolve, speed: 0.5)

    text('Credits?').
      font('GeorgiaB').
      font_size(100 * production.resolution.width / 1600).
      gravity('Center').
      fill('RoyalBlue1').
      enter(2).
      in(:dissolve, speed: 0.25)
  end
end

scene 'Credits Image' do
  start voice_in + time('3:21.3')
  script <<-SCRIPT
    First, we create a tall image listing the folks we want to credit,
  SCRIPT

  plan do
    matte(:white).enter(-0.5).in(:dissolve, speed: 0.5)

    sprite('castaway-credits.png').
      size(nil, production.resolution.height * 0.9).
      gravity(:center).
      enter(-0.5).in(:dissolve, speed: 0.5)
  end
end

scene 'Declare Credits' do
  start voice_in + time('3:25.9')
  script <<-SCRIPT
    describe it as a "sprite" in the Castaway script (so it won't be forced to
    the frame's resolution), and resize it so it has the same width as the
    frame.
  SCRIPT

  plan do
    still('declare-credits.png').enter(-0.5).in(:dissolve, speed: 0.5)
  end
end

scene 'Pan Credits' do
  start voice_in + time('3:35.8')
  script <<-SCRIPT
    Then, we add a "pan" command, telling it to pan vertically over the course
    of a few seconds. We put an explicit "exit" command in there, so that we
    can have the bottom of our credit screen stick around for a few more seconds
    before fading to black.
  SCRIPT

  plan do
    still('pan-credits.png').enter(-0.5).in(:dissolve, speed: 0.5)
  end
end

scene 'Credits' do
  start voice_in + time('3:49.8')
  script <<-SCRIPT
    The result? Some lovely scrolling credits! Thanks for watching, and happy
    casting.
  SCRIPT

  plan do
    sprite('castaway-credits.png').
      size(production.resolution.width, nil).
      enter(-0.5).in(:dissolve, speed: 0.5).
      effect(:pan, vertical: true, from: 1, to: 11)
  end
end

scene 'Fade to Black' do
  start voice_in + time('4:03')

  plan do
    matte(:black).enter(-0.5).in(:dissolve, speed: 0.5)
  end
end

finish voice_in + time('4:05')
