class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # before_filter :filtro_acesso, :verifica_permissao, :define_navegacao, :authorize_usuario, unless: -> {
  #   efetuando_login?
  # }

  before_filter :filtro_acesso, :verifica_permissao, :define_navegacao, :authorize_usuario, unless: -> {
    efetuando_login?
  }

  def filtro_acesso

        @sessao = OpenStruct.new(
          :id => '20150504085648H4SV4K1BJ6KA4RR5JNDQ0DBS66LWDX1Z1V2TNHV7M0RF2EPDVE5Y4RD4SN26',
          :usuario => OpenStruct.new(
            :matricula => 'admin',
            :id => '1245',
            :nome => 'Administrador'
          ),
          :perfis => [
            OpenStruct.new(:nome => 'administrador', :unidades=>  [OpenStruct.new(:id => '3739', :nome => "DIRETORIA DE GESTAO DE INFORMAÇAO")])
          ]
        )

        session[:sessao_id] = @sessao.id
        session[:usuario] = usuario_autenticado.matricula

        verificar_cadastro_e_valorizar_sessao

        return true
  end

  def usuario_autenticado
    @sessao.usuario
  end

  def perfis_do_usuario
    @sessao.perfis.map(&:nome)
  end

  def usuario_sem_acesso
    redirect_to 'http://localhost:3000/sem_acesso'
  end

  def definir_view_por_grupo(perfil)
    partial = {
        "usuario" => Proc.new { "#{controller_name}/#{action_name}" },
        "administrador" => Proc.new { "#{controller_name}/#{perfil}/#{action_name}" },
        "gestor" => Proc.new { "#{controller_name}/#{perfil}/#{action_name}" }
    }
    partial[perfil].call
  end

  def verifica_permissao
    permissoes_usuario = nil

    unless (session[:is_admin] || permissoes_usuario.include?(controller_name))
        #flash.now[:alert] = "Usuário sem permissão de acesso."
        redirect_to home_index_path, :alert => "Usuário sem permissão de acesso."
    end
  end

  private

  def is_perfil_admin_arca?
    perfis_do_usuario.include?("Administrador")
  end

  def verificar_cadastro_e_valorizar_sessao

      session[:nome] = "Juraci Santos"
      session[:usuario_id] = 1
      session[:area_responsavel_id] = 1
      session[:is_admin] = true
      session[:perfil] = "administrador"
  end

  def define_navegacao
    @links_navegacao = Array.new
    @links_navegacao << {:path => controller_name, :text => (t "#{controller_name}.#{action_name}.title") }
  end

  def current_usuario
    @current_usuario = "1"
  end

  def authorize_usuario
    unless current_usuario
      redirect_to '/login', alert: "É necessário autenticação para visualizar estas informações."
    end
  end

  def is_usuario?
    !session[:usuario_id].nil?
  end

  def is_admin?
    session[:is_admin]
  end

  def is_perfil_de_usuario?
    return session[:perfil] == "usuario"
  end

  def login_efetuado?
    is_usuario?
  end

  def efetuando_login?
    ["login", "sem_acesso"].include?(controller_name)
  end

  def define_message_sucess(model)
    t 'message_sucess', :default => '', :model => model, :acao => (t "#{action_name}")
  end

  helper_method :current_usuario, :is_usuario?, :login_efetuado?, :is_admin?, :efetuando_login?
end
