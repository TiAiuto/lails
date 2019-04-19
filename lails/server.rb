# ここでは起動処理を実行する

require '../lails/active_record_base'
require '../lails/action_controller_base'

require '../../rails_tutorial/sample_app/app/models/application_record'
require '../../rails_tutorial/sample_app/app/models/user'

require '../../rails_tutorial/sample_app/app/helpers/sessions_helper'

require '../../rails_tutorial/sample_app/app/controllers/application_controller'
require '../../rails_tutorial/toy/app/controllers/users_controller'

catch :abort do
  # ここが一つのトランザクションになる

  user = User.new
  # user.save

  controller = UsersController.new
  puts controller._invoke(:new)
end
