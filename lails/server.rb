# ここでは起動処理を実行する

require '../lails/rails'
require '../../rails_tutorial/sample_app/app/helpers/application_helper'

require '../lails/active_record_base'
require '../lails/action_controller_base'

require '../../rails_tutorial/sample_app/app/models/application_record'
require '../../rails_tutorial/sample_app/app/models/user'

# 本当はここで入れるんじゃない
require '../../rails_tutorial/sample_app/app/helpers/sessions_helper'

require '../../rails_tutorial/sample_app/app/controllers/application_controller'
require '../../rails_tutorial/toy/app/controllers/users_controller'

require 'webrick'


srv = WEBrick::HTTPServer.new({
                                DocumentRoot: './',
                                BindAddress:  '0.0.0.0',
                                Port:         '8080',
                              })

srv.mount_proc '/' do |req, res|
  catch :abort do
    # ここが一つのトランザクションになる

    user = User.new
    # user.save

    controller = UsersController.new
    res.body   = controller._invoke(:new)
  end
end

srv.start
