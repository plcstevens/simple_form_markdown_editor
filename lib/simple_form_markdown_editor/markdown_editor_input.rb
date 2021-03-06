require 'simple_form'
require 'i18n'

module SimpleFormMarkdownEditor
  class MarkdownEditorInput < SimpleForm::Inputs::Base
    class << self
      attr_accessor :configuration

      def configure
        @configuration ||= Configuration.new
        yield @configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end
    end

    # =====================================================================

    def input(wrapper_options)
      attrs = merge_wrapper_options(input_html_options, wrapper_options)
      attrs[:data] ||= {}
      attrs[:data][:preview_path] = preview_path
      attrs[:data][:options] = { render_class: render_class.to_s, render_options: render_options, extensions: extensions }

      template.content_tag :div, attrs do
        template.concat header
        template.concat help
        template.concat editor
        template.concat preview
      end
    end

    private # =============================================================

    def preview_path
      options.fetch(:route, MarkdownEditorInput.configuration.route)
    end

    def render_class
      options.fetch(:render_class, MarkdownEditorInput.configuration.render_class)
    end

    def render_options
      options.fetch(:render_options, MarkdownEditorInput.configuration.render_options)
    end

    def extensions
      options.fetch(:extensions, MarkdownEditorInput.configuration.extensions)
    end

    def input_html_classes
      super.push('simple_form_markdown_editor')
    end

    def header
      template.content_tag :div, class: 'header' do
        tabs + buttons
      end.html_safe
    end

    # ---------------------------------------------------------------------

    def tabs
      template.content_tag :div, class: 'editor_tabs' do
        template.content_tag :ul, class: 'tabs' do
          tab_list.map { |t| tab(t) }.flatten.join.html_safe
        end
      end
    end

    def tab_list
      %w(edit preview)
    end

    def tab(name)
      template.content_tag :li, class: ['tab', name.to_s.underscore.downcase], data: { command: name.to_s } do
        template.content_tag(
          :span,
          I18n.t(name.to_sym, scope: 'simple_form_markdown_editor.tabs'),
          class: name.to_s.underscore.downcase
        )
      end
    end

    # ---------------------------------------------------------------------

    def buttons
      template.content_tag :div, class: 'buttons' do
        button_groups
      end
    end

    def button_groups
      template.content_tag :ul, class: 'button_groups' do
        button_list.map { |group| button_group(group) }.flatten.join.html_safe
      end
    end

    def button_group(g)
      template.content_tag :li, class: 'button_group', data: { buttons: g.join(' ') } do
        template.content_tag :ul, class: 'buttons' do
          g.map { |b| button(b) }.flatten.join.html_safe
        end
      end
    end

    def button(b)
      return if b == 'help' && !help_enabled?
      template.content_tag :li, class: ['button', b], data: { toggle: b } do
        template.content_tag(
          :button,
          I18n.t(b.to_sym, scope: 'simple_form_markdown_editor.buttons'),
          class: b,
          name: '',
          role: '',
          state: '',
          type: 'button',
          value: b
        )
      end
    end

    def button_list
      options[:buttons].presence || MarkdownEditorInput.configuration.buttons
    end

    # ---------------------------------------------------------------------

    def editor
      template.content_tag :div, class: %w(editor) do
        @builder.text_area(attribute_name, input_html_options).html_safe
      end
    end

    def preview
      template.content_tag(
        :div,
        I18n.t(:loading, scope: 'simple_form_markdown_editor'),
        class: %w(preview),
        data: { nothing_to_preview_text: I18n.t(:nothing_to_preview, scope: 'simple_form_markdown_editor') }
      )
    end

    # ---------------------------------------------------------------------

    def help
      return unless help_enabled?
      template.content_tag :div, class: %w(help), data: { visible: help_visible? } do
        template.content_tag :div, class: %w(help_wrapper) do
          help_sections + help_sub_sections + help_texts
        end
      end
    end

    def help_sections
      template.content_tag :ul, class: %w(sections) do
        i18n_help.map { |section, content| help_section(section, content) }.flatten.join.html_safe
      end
    end

    def help_section(section, content)
      return unless content[:title]
      template.content_tag :li, class: ['section', section.to_s], data: { toggle: section.to_s } do
        template.content_tag :span, content[:title].to_s, class: section.to_s
      end.html_safe
    end

    def help_sub_sections
      i18n_help.map do |section, content|
        template.content_tag :ul, class: ['sub_sections', section.to_s] do
          content[:elements].map { |sec, con| help_sub_section(sec, con) }.flatten.join.html_safe
        end
      end.flatten.join.html_safe
    end

    def help_sub_section(section, content)
      return unless content[:title]
      template.content_tag :li, class: ['sub_section', section.to_s], data: { toggle: section.to_s } do
        template.content_tag :span, content[:title].to_s, class: section.to_s
      end.html_safe
    end

    def help_texts
      i18n_help.map do |section, content|
        content[:elements].map do |el, con|
          template.content_tag :div, class: ['help_text', el.to_s], data: { section: section.to_s, sub_section: el.to_s } do
            Renderer.call(con[:text], render_class: render_class, render_options: render_options, extensions: extensions)
          end
        end
      end.flatten.join.html_safe
    end

    # ---------------------------------------------------------------------

    def i18n_help
      I18n.t(:help, scope: 'simple_form_markdown_editor')
    end

    def help_enabled?
      enabled_in_options = options.fetch(:help, {}).fetch(:enabled, nil)
      enabled_in_config = MarkdownEditorInput.configuration.help.fetch(:enabled, false)

      return enabled_in_config if enabled_in_options.nil?

      enabled_in_options
    end

    def help_visible?
      visible_in_options = options.fetch(:help, {}).fetch(:visible, nil)
      visible_in_config = MarkdownEditorInput.configuration.help.fetch(:visible, false)

      return visible_in_config if visible_in_options.nil?

      visible_in_options
    end
  end
end
