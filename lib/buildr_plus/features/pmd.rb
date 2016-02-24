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

module BuildrPlus
  class PmdConfig
    class << self
      def default_pmd_rules
        'au.com.stocksoftware.pmd:pmd:xml:1.2'
      end

      def pmd_rules
        @pmd_rules || self.default_pmd_rules
      end

      def pmd_rules=(pmd_rules)
        @pmd_rules = pmd_rules
      end
    end
  end
  module CheckstyleExtension
    module ProjectExtension
      include Extension

      after_define do |project|
        project.pmd.rule_set_artifacts << PmdConfig.pmd_rules if project.pmd.enabled?
      end
    end
  end
end

class Buildr::Project
  include BuildrPlus::CheckstyleExtension::ProjectExtension
end
