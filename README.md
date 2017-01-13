# Castaway

Want to create an online presentation or screencast, but are frustrated by
complicated interfaces or expensive tools? Maybe you're using one that _almost_
does what you need, but that one feature it's missing is a deal-breaker?

_Castaway_ to the rescue! Write your scripts, mix your audio, and render your
video, all via a simple-yet-powerful DSL.

Want to rerender your video with a different resolution or framerate? No
problem--just run the script with different parameters.

Is that arrow pointing at the wrong point, or does that animation start at the
wrong time? Easy-peasy. Change the position or timing in your script, and rerun
it.

Screencasting just got a whole lot easier.


## Installation

Castaway depends on a few external tools to do the heavy lifting. You'll need to
make sure you have the following tools installed:

* [ImageMagick](https://www.imagemagick.org/script/binary-releases.php) is used
  to render video frames and special effects. _(Tested with version 6.9.5)_
* [Sox](https://sourceforge.net/projects/sox/files/sox/) is used to edit and mix
  audio. _(Tested with version 14.4.2)_
* [FFmpeg](https://ffmpeg.org/download.html) is used to combine the frames and
  audio into a single video file. _(Tested with version 3.2.2)_

Once you've met those requirements, installing Castaway itself is simple:

    $ gem install castaway

And you're good to go!


## Usage

Scripts are written in a DSL in Ruby. You declare scenes and sound clips,
and describe what comprises those scenes and sound clips. Here's a simple
example:

```ruby
soundclip :theme, resource('music.wav')

soundtrack do |clip|
  clip.in soundclip(:theme)
  # fade in the theme music
  clip.chain.fade(5, type: :linear)
end

scene 'Title Screen' do
  start '0:00'
  script 'Hello, and welcome to our new screencast!'

  plan do
    # start with a black screen
    matte(:black).
      exit(1)

    # dissolve-in our title screen
    still('title.png').
      enter(0.5).
      in(:dissolve, speed: 0.5)
  end
end

finish '0:10'
```

This declares a sound track that fades in over five seconds, as well as a
single scene that displays a still frame, dissolved in at the 0.5 second mark.
The whole finishes at the ten second mark. If this were saved as `script.rb`,
you could generate the video like so:

    $ castaway build script.rb

This will generate the frames, mix the audio, and compose the whole together
into a video called `script.mp4` (it uses the name of the script file as the
default for naming the video).

To name it something else:

    $ castaway build -o movie.mp4 script.rb

By default, the video will be rendered at 540p (960x540 pixels). Change this
with the `--resolution` parameter:

    $ castaway build --resolution 1080p script.rb

You can specify either HD-style resolutions (1080p, 540p, etc.) or WIDTHxHEIGHT
resolutions (e.g. 960x540).

Also by default, video will be rendered at NTSC-standard 29.97 frames/second.
To change the number of frames per second, use the `--fps` parameter:

    $ castaway build --fps 10 script.rb

This can be useful for previewing a build quickly, before building the final
movie.


## Caveats

This is a work in progress, and will probably not do everything you need just
yet. Documentation and examples are severely lacking.

But stay tuned!


## Author

Castaway was written by Jamis Buck (jamis@jamisbuck.org).


## License

Castaway is distributed under the MIT license. (See the `MIT-LICENSE` file for
details).
