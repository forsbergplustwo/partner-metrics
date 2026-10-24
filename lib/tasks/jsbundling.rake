# jsbundling-rails 1.1.2 hardcodes `yarn install` / `yarn build`.
# Route those tasks through pnpm so this repo has one JS package manager.

if Rake::Task.task_defined?("javascript:install")
  Rake::Task["javascript:install"].clear
end
if Rake::Task.task_defined?("javascript:build")
  Rake::Task["javascript:build"].clear
end

namespace :javascript do
  desc "Install JavaScript dependencies"
  task :install do
    unless system("pnpm", "install", "--frozen-lockfile")
      raise "jsbundling-rails: Command install failed, ensure pnpm is installed"
    end
  end

  desc "Build your JavaScript bundle"
  build_task = task :build do
    unless system("pnpm", "build")
      raise "jsbundling-rails: Command build failed, ensure `pnpm build` runs without errors"
    end
  end
  build_task.prereqs << :install unless ENV["SKIP_YARN_INSTALL"]
end
