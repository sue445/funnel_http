require "rake"
require "rake/tasklib"

class RakeTask < ::Rake::TaskLib
  # @!attribute [r] gem_name
  # @return [String]
  attr_reader :gem_name

  # @!attribute task_namespace
  #   @return [Symbol] task namespace (default: `:go`)
  attr_accessor :task_namespace

  # @!attribute go_executable_path
  #   @return [String] path to executable go path (default: `"go"`)
  attr_accessor :go_executable_path

  # @!attribute test_args
  #   @return [String] argument passed to `go test` (default: `"-mod=readonly -count=1"`)
  attr_accessor :test_args

  # @param gem_name [String]
  # @yield configuration of {RakeTask}
  # @yieldparam config [RakeTask]
  def initialize(gem_name)
    super()

    @gem_name = gem_name

    @task_namespace = :go
    @go_executable_path = "go"
    @test_args = "-mod=readonly -count=1"

    yield(self) if block_given?

    namespace(task_namespace) do
      desc "Run go test"
      task(:test) do
        within_ext_dir do
          sh RakeTask.build_env_vars, "#{go_executable_path} test #{test_args} ./..."
        end
      end
    end
  end

  # Generate environment variables for go build with CRuby
  #
  # @return [Hash<String, String>]
  def self.build_env_vars
    ldflags = "-L#{RbConfig::CONFIG["libdir"]} -l#{RbConfig::CONFIG["RUBY_SO_NAME"]}"

    case `#{RbConfig::CONFIG["CC"]} --version` # rubocop:disable Lint/LiteralAsCondition
    when /Free Software Foundation/
      ldflags << " -Wl,--unresolved-symbols=ignore-all"
    when /clang/
      ldflags << " -undefined dynamic_lookup"
    end

    cflags = "#{RbConfig::CONFIG["CFLAGS"]} -I#{RbConfig::CONFIG["rubyarchhdrdir"]} -I#{RbConfig::CONFIG["rubyhdrdir"]}"

    # FIXME: Workaround for GitHub Actions
    if ENV["GITHUB_ACTIONS"]
      cflags.gsub!("-Wno-self-assign", "")
      cflags.gsub!("-Wno-parentheses-equality", "")
      cflags.gsub!("-Wno-constant-logical-operand", "")
      cflags.gsub!("-Wsuggest-attribute=format", "")
      cflags.gsub!("-Wold-style-definition", "")
      cflags.gsub!("-Wsuggest-attribute=noreturn", "")
      ldflags.gsub!("-Wl,--unresolved-symbols=ignore-all", "")
    end

    ld_library_path = RbConfig::CONFIG["libdir"]

    {
      "CGO_CFLAGS"      => cflags,
      "CGO_LDFLAGS"     => ldflags,
      "LD_LIBRARY_PATH" => ld_library_path,
    }
  end

  private

  # @yield
  def within_ext_dir
    Dir.chdir(ext_dir) do
      yield
    end
  end

  # @return [String]
  def ext_dir
    File.join("ext", gem_name)
  end
end
