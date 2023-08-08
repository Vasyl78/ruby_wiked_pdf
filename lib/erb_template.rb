# frozen_string_literal: true

module ErbTemplate
  include Constants::Templates

  def generate(template:, t_format: :html, layout: nil, skip_layout: false)
    if skip_layout
      generate_str(template:, t_format:)
    else
      with_layout(*[layout].compact, t_format:) { generate_str(template:, t_format:) }
    end
  end

  def generate_html(template:, layout: nil, skip_layout: false)
    generate(template:, t_format: :html, layout:, skip_layout:)
  end

  def generate_json(template:, layout: nil, skip_layout: false)
    generate(template, t_format: :json, layout:, skip_layout:)
  end

  def render_erb(file_path)
    file = File.open(file_path)
    ERB.new(file.read).result(binding)
  end

  def render_partial(template, t_format: :html)
    generate_str(template:, t_format:)
  end

  private

  def with_layout(layout = "layouts/default", t_format: :html, &block)
    generate_str(template: layout, t_format:, &block)
  end

  def generate_str(template:, t_format: :html, &block)
    template_path = File.join(PATH, "#{template}.#{t_format}.erb")
    render_erb(template_path, &block)
  end
end
