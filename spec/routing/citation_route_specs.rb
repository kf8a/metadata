describe 'routing articles and books' do
  it 'routes article_citations' do
    { :get => "/artcile_citations".should route_to(
      :controller => 'citations')
    }
  end
end
