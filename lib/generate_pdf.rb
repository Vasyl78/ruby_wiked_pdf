# frozen_string_literal: true

class GeneratePdf
  attr_reader :html_content,
              :out_path,
              :pdf_config

  def initialize(html_config: {}, pdf_config: {}, save_html: false, template_data: {})
    @html_content = HtmlContent.new(**html_config.merge(template_data:))
    @save_html = save_html
    @pdf_config = pdf_config
    @out_path = File.join(Constants::App::APP_ROOT, "output", Time.now.strftime("%Y/%m-%d"))
  end

  def save_html?
    @save_html
  end

  def generate
    FileUtils.mkdir_p(out_path)
    html_content.initialize_content
    write_to_file(html_content.body_content, "html") if save_html?

    pdf = WickedPdf.new.pdf_from_string(html_content.body_content, pdf_options)
    write_to_file(pdf, "pdf")
  end

  private

  def write_to_file(content, extention)
    file_name = File.join(out_path, "#{Time.now.strftime('%H_%M_%S')}.#{extention}")
    File.write(file_name, content, mode: "wb")
  end

  def pdf_options
    {
      margin: pdf_config[:margin],
      header: { content: html_content.header_content },
      footer: { content: html_content.footer_content },
      orientation: pdf_config[:orientation]
    }.compact
  end
end
