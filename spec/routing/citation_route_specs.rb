describe 'routing articles and books' do
  it 'routes article_citations' do
    { get: '/article_citations' }.should route_to(controller: 'citations', action: 'index')
  end
end
