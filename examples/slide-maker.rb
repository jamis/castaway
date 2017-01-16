# Converts the code snippets in the `snippets` directory, into PDF's that
# can then be converted into images, for the `images` directory.
#
# You only need to run this if you change any of the snippets in the `snippets`
# directory.

require 'fileutils'
require 'code_slide'

font_path = File.expand_path(
  File.join('~',
            '.atom',
            'packages',
            'fonts',
            'resources',
            'roboto'))

Dir.chdir(File.dirname(__FILE__)) do
  output_path = '_pdf'
  FileUtils.mkdir_p(output_path)

  Dir[File.join('snippets', '*.rb')].each do |file|
    snippet = CodeSlide::Snippet.from_file(file)

    snippet.use_font File.join(font_path, 'roboto.ttf'),
                     bold: File.join(font_path, 'roboto-bold.ttf'),
                     italic: File.join(font_path, 'roboto-italic.ttf'),
                     bold_italic: File.join(font_path, 'roboto-bold-italic.ttf')

    output = File.join(output_path,
                       File.basename(file, File.extname(file)) + '.pdf')

    snippet.make_pdf(output, font_size: 28, page_width: 1600, page_height: 900)
  end
end
