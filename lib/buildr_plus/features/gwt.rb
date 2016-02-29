#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if BuildrPlus::Util.is_addon_loaded?('gwt')
  module BuildrPlus
    class Gwt
      class << self
        def gwtc_java_args
          %w(-ea -Djava.awt.headless=true -Xms512M -Xmx1024M -XX:PermSize=128M -XX:MaxPermSize=256M)
        end
      end
    end
  end
end