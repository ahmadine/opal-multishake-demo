require 'bundler'
Bundler.setup
require 'opal'
require 'opal/browser'
Opal.append_path("./opal")

app="example"

directory "dist"

apps = ["opal_base", "opal_mini", "opal_std", "opal_x_browser"]

apps.each do |app|
  file "dist/#{app}.js" => ["dist"] do
    builder = Opal::Builder.new
    builder.compiler_options[:method_missing] = true
    builder.compiler_options[:const_missing] = false
    builder.compiler_options[:freezing] = false
    builder.compiler_options[:tainting] = false
    src = builder.build("#{app}")
    File.write("dist/#{app}.js", src)
  end

  file "dist/#{app}.shake.js" => ["dist/#{app}.js"] do
    `bin/multishake.sh dist/#{app}.js > dist/#{app}.shake.js`
  end

  ["", ".shake"].each do |shake|
    file "dist/#{app}#{shake}.min.js" => ["dist/#{app}#{shake}.js"] do
      `npx google-closure-compiler --language_out ECMASCRIPT5_STRICT --js dist/#{app}#{shake}.js --js_output_file dist/#{app}#{shake}.min.js`
    end

    file "dist/#{app}#{shake}.min.js.gz" => ["dist/#{app}#{shake}.min.js"] do
      `gzip -c9 dist/#{app}#{shake}.min.js > dist/#{app}#{shake}.min.js.gz`
    end

    file "dist/#{app}#{shake}.min.js.br" => ["dist/#{app}.min.js"] do
      `brotli -cZ dist/#{app}#{shake}.min.js > dist/#{app}#{shake}.min.js.br`
    end
  end

  # Regular build
  task "#{app}_build" => ["dist/#{app}.min.js.gz", "dist/#{app}.min.js.br"]
  # Shaked build
  task "#{app}_shake" => ["dist/#{app}.shake.min.js.gz", "dist/#{app}.shake.min.js.br"]

  task "#{app}_test" => ["#{app}_build", "#{app}_shake"] do
    ["dist/#{app}.js",
     "dist/#{app}.min.js",
     "dist/#{app}.shake.js",
     "dist/#{app}.shake.min.js"
    ].each do |file|
      start = Time.now
      if `node #{file}` == "Hello world!\n"
        puts "Success: #{file} (#{Time.now - start}s)"
      else
        puts "Error: #{file}"
      end
    end
  end

  task "#{app}" => [:clean, "#{app}_build", "#{app}_shake", "#{app}_test"]
end

task :clean do
  FileUtils.rm_rf "dist"
end

task :build => apps.map { |i| "#{i}_build" }
task :shake => apps.map { |i| "#{i}_shake" }
task :test => apps.map { |i| "#{i}_test" }

task :size do
  Dir["dist/*.shake.*"].each do |shaked|
    unshaked = shaked.dup
    unshaked[".shake"] = ""

    sz_shaked = File.size(shaked)
    sz_unshaked = File.size(unshaked)

    reduction = 100.0 * (sz_unshaked - sz_shaked) / sz_unshaked

    puts "#{unshaked}: #{sz_unshaked} -> #{sz_shaked} (#{reduction.round(2)}% reduction)"
  end
end

task :default => [:clean, :build, :shake, :test]
