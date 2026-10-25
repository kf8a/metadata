import { application } from 'controllers/application'

import AutocompleteController from 'controllers/autocomplete_controller'
import NestedFieldsController from 'controllers/nested_fields_controller'
import ObfuscatedEmailController from 'controllers/obfuscated_email_controller'
import PermissionRequestController from 'controllers/permission_request_controller'
import QcGraphController from 'controllers/qc_graph_controller'
import ScoreCardController from 'controllers/score_card_controller'

application.register('autocomplete', AutocompleteController)
application.register('nested-fields', NestedFieldsController)
application.register('obfuscated-email', ObfuscatedEmailController)
application.register('permission-request', PermissionRequestController)
application.register('qc-graph', QcGraphController)
application.register('score-card', ScoreCardController)

export { application }
