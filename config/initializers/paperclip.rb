Paperclip.options[:content_type_mappings] = {
  do: %w[text/plain, text/x-matlab]
}

worrisome_adapters = [Paperclip::UriAdapter, Paperclip::HttpUrlProxyAdapter,
                      Paperclip::DataUriAdapter]

Paperclip.io_adapters
         .registered_handlers
         .delete_if do |_block, handler_class|
           worrisome_adapters.include?(handler_class)
         end
