module ApplicationHelper

	def javascript(*files)
	  content_for(:head) { javascript_include_tag(*files) }
	end

	def stylesheet(*files)
	  content_for(:head) { stylesheet_link_tag(*files) }
	end

	def mark_required(object, attribute)
	  "*" if object.class.validators_on(attribute).map(&:class).include? ActiveRecord::Validations::PresenceValidator
	end

	def define_helper_type(type, value)
    helper_type = {
      "text" => Proc.new { text_field_tag "resposta[resposta]", value, :class => "span7" },
      "date" => Proc.new { text_field_tag "resposta[resposta]", value, :class => "span7 input-mask-date" },
      "number" => Proc.new { number_field_tag "resposta[resposta]", value, :class => "span7" },
  	  "monay" => Proc.new { text_field_tag "resposta[resposta]", value, :class => "span7 monay" },
      "boolean" => Proc.new { 
        "
          #{radio_factory(true)}
          <span class='lbl'> #{true.humanize} </span>
          #{radio_factory(false)}
          <span class='lbl'> #{false.humanize} </span>
        ".html_safe
        
      }
    }

    helper_type[type].call(value) 
  end

  def radio_factory(valor)
    radio_button_tag "resposta[resposta]", valor, false 
  end

	def define_head
    	["login"].include?(controller_name) ? 'login-layout' : ''
  end

  def define_title
		t "#{controller_name}.#{action_name}.title", :default => "Erro ao salvar #{controller_name}"
	end

	def define_sub_title
		valor = t "#{controller_name}.#{action_name}.sub_title", :default => ''

		"<small>
			<i class='icon-double-angle-right'></i>
			#{valor}
		</small>".html_safe unless valor == ''
	end

	def show_link(args)
	  link_to args[:link_source], {:data => args[:data], :method => args[:method], :title => args[:title], :class => "#{args[:link_style]}" } do
	    "#{content_tag :i, nil, class: args[:icon_class]} #{args[:link_text]}".html_safe
	  end
	end

	def link_new_model(args)
		unless args[:model].nil? || args[:path].nil?
	  		link_to t('.new_model', :default => t('new_model', :model => args[:model].class.model_name.human, )), args[:path], :class => "btn btn-primary"
	    else
	      raise "Deve ser passado os argumentos model e path. Ex: {:model => Model.class_name, :path => new_meta_path}"
	    end
	end

	def define_descricao_botao_ativar(is_ativo, objeto)
	    texto = is_ativo ?  "Desativar" : "Ativar"
	    style = is_ativo ? "btn-danger" : "btn-sucsces"
	    icone = is_ativo ? "icon-remove" : "icon-ok"
	    mensagem = is_ativo ? "Deseja desativar?" : "Deseja ativar?"

	    show_link ({:link_text => texto, :link_source => objeto, :link_style => "btn btn-mini #{style}", :icon_class => "#{icone}", method: :delete, data: { confirm: "#{mensagem}" }})
	end

  def campo_obrigatorio(descricao)
    "*#{descricao}"
  end

  def imagem(controle)
    image_tag "#{controle}.png", :width => '20px;'
  end

  def texto_menu(controle)
    t "#{controle}.index.title"
  end

  def define_menu
    menu = ''
    if session[:perfil] == Usuario::ADMINISTRADOR
      Usuario::PERMISSOES_ADMINISTRADOR.each do |controle|
        menu << "<li id='#{controle}' class='#{controller_ativo(controle)}'>
                    <a href='/#{controle}' id='#{controle}' >
                       <i> #{imagem(controle)} </i>
                        <span class='menu-text'> #{ texto_menu(controle) } </span>
                    </a>
                </li>" unless controle=="home"
      end
    end
    if session[:perfil] == Usuario::USUARIO
      Usuario::PERMISSOES_USUARIO.each do |controle|
        menu << "<li>
                    <a href='/#{controle}' >
                       <i> #{imagem(controle)} </i>
                        <span class='menu-text'> #{ texto_menu(controle) } </span>
                    </a>
                </li>" unless controle=="home"
      end
    end
    return menu.html_safe
  end

  private

  def controller_ativo(controller_atual)
    controller_atual==controller_name ? 'active' : ''
  end

end

