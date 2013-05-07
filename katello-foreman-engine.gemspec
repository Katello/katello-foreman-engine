Gem::Specification.new do |s|
  s.name = "katello-foreman-engine"
  s.version = "0.0.1"

  s.authors = ["Katello"]
  s.date = "2013-04-19"
  s.description = "Foreman specific parts in Katello"
  s.email = "katello-devel@redhat.com"
  s.files = `git ls-files`.split("\n")
  s.homepage = "http://github.com/katello/katello-foreman-engine"
  s.licenses = ["GPL-2"]
  s.require_paths = ["lib"]
  s.add_dependency "foreman_api"
  s.add_dependency "deface", "~> 0.7.2"
  s.add_dependency "dynflow"
  s.summary = "Foreman specific parts of Katello"
end
