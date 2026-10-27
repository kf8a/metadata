import { application } from 'controllers/application'

import AutocompleteController from 'controllers/autocomplete_controller'
import NestedFieldsController from 'controllers/nested_fields_controller'
import ObfuscatedEmailController from 'controllers/obfuscated_email_controller'
import PermissionRequestController from 'controllers/permission_request_controller'
import TreeController from 'controllers/tree_controller'

application.register('autocomplete', AutocompleteController)
application.register('nested-fields', NestedFieldsController)
application.register('obfuscated-email', ObfuscatedEmailController)
application.register('permission-request', PermissionRequestController)
application.register('tree', TreeController)

export { application }
