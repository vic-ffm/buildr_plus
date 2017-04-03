# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with this
# work for additional information regarding copyright ownership.  The ASF
# licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.

class Buildr::CustomPom
  def self.pom_xml(project, package)
    Proc.new do
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      xml.project('xmlns' => 'http://maven.apache.org/POM/4.0.0',
                  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                  'xsi:schemaLocation' => 'http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd') do
        xml.modelVersion '4.0.0'
        xml.parent do
          xml.groupId 'org.sonatype.oss'
          xml.artifactId 'oss-parent'
          xml.version '7'
        end
        xml.groupId project.group
        xml.artifactId project.id
        xml.version project.version
        candidates = project.packages.select { |p| p.classifier.nil? }.collect { |p| p.type.to_s }
        packaging = !candidates.empty? ? candidates[0] : (project.compile.packaging || :zip).to_s
        xml.packaging packaging

        xml.name project.pom.name if project.pom.name
        xml.description project.pom.description if project.pom.description
        xml.url project.pom.url if project.pom.url

        xml.licenses do
          project.pom.licenses.each_pair do |name, url|
            xml.license do
              xml.name name
              xml.url url
              xml.distribution 'repo'
            end
          end
        end unless project.pom.licenses.empty?

        if project.pom.scm_url || project.pom.scm_connection || project.pom.scm_developer_connection
          xml.scm do
            xml.connection project.pom.scm_connection if project.pom.scm_connection
            xml.developerConnection project.pom.scm_developer_connection if project.pom.scm_developer_connection
            xml.url project.pom.scm_url if project.pom.scm_url
          end
        end

        if project.pom.issues_url
          xml.issueManagement do
            xml.url project.pom.issues_url
            xml.system project.pom.issues_system if project.pom.issues_system
          end
        end

        xml.developers do
          project.pom.developers.each do |developer|
            xml.developer do
              xml.id developer.id
              xml.name developer.name if developer.name
              xml.email developer.email if developer.email
              if developer.roles
                xml.roles do
                  developer.roles.each do |role|
                    xml.role role
                  end
                end
              end
            end
          end
        end unless project.pom.developers.empty?

        provided_deps = Buildr.artifacts(project.pom.provided_dependencies).collect { |d| d.to_s }
        runtime_deps = Buildr.artifacts(project.pom.runtime_dependencies).collect { |d| d.to_s }
        optional_deps = Buildr.artifacts(project.pom.optional_dependencies).collect { |d| d.to_s }
        deps =
          Buildr.artifacts(project.compile.dependencies).
            select { |d| d.is_a?(ActsAsArtifact) }.
            collect do |d|
            f = d.to_s
            scope = provided_deps.include?(f) ? 'provided' :
              runtime_deps.include?(f) ? 'runtime' :
                'compile'
            d.to_hash.merge(:scope => scope, :optional => optional_deps.include?(f))
          end + Buildr.artifacts(project.test.compile.dependencies).
            select { |d| d.is_a?(ActsAsArtifact) && !project.compile.dependencies.include?(d) }.collect { |d| d.to_hash.merge(:scope => 'test') }

        xml.dependencies do
          deps.each do |dependency|
            xml.dependency do
              xml.groupId dependency[:group]
              xml.artifactId dependency[:id]
              xml.version dependency[:version]
              xml.scope dependency[:scope] unless dependency[:scope] == 'compile'
              xml.optional true if dependency[:optional]
              xml.exclusions do
                xml.exclusion do
                  xml.groupId '*'
                  xml.artifactId '*'
                end
              end
            end
          end
        end unless deps.empty?
      end
    end
  end
end