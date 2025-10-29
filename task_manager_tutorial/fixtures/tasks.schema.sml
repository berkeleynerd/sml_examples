<schema>
  <element name="task_database">
    <complexType>
      <sequence>
        <element name="metadata">
          <complexType>
            <sequence>
              <element name="version" type="string"/>
              <element name="last_updated" type="date"/>
            </sequence>
          </complexType>
        </element>

        <element name="projects">
          <complexType>
            <sequence>
              <element name="project" minOccurs="0" maxOccurs="unbounded">
                <complexType>
                  <sequence>
                    <element name="name" type="string">
                      <simpleType>
                        <restriction base="string">
                          <maxLength value="100"/>
                        </restriction>
                      </simpleType>
                    </element>
                    <element name="description" type="string" minOccurs="0"/>
                    <element name="status">
                      <simpleType>
                        <restriction base="string">
                          <enumeration value="planning"/>
                          <enumeration value="active"/>
                          <enumeration value="on_hold"/>
                          <enumeration value="completed"/>
                          <enumeration value="cancelled"/>
                        </restriction>
                      </simpleType>
                    </element>
                    <element name="created" type="date"/>
                    <element name="owner" type="string"/>
                    <element name="deadline" type="date" minOccurs="0"/>
                  </sequence>
                  <attribute name="id" type="string" use="required"/>
                </complexType>
              </element>
            </sequence>
          </complexType>
        </element>

        <element name="tasks">
          <complexType>
            <sequence>
              <element name="task" minOccurs="0" maxOccurs="unbounded">
                <complexType>
                  <sequence>
                    <element name="title" type="string">
                      <simpleType>
                        <restriction base="string">
                          <minLength value="1"/>
                          <maxLength value="200"/>
                        </restriction>
                      </simpleType>
                    </element>
                    <element name="description" type="string" minOccurs="0"/>
                    <element name="priority">
                      <simpleType>
                        <restriction base="integer">
                          <minInclusive value="1"/>
                          <maxInclusive value="5"/>
                        </restriction>
                      </simpleType>
                    </element>
                    <element name="status">
                      <simpleType>
                        <restriction base="string">
                          <enumeration value="todo"/>
                          <enumeration value="in_progress"/>
                          <enumeration value="blocked"/>
                          <enumeration value="review"/>
                          <enumeration value="done"/>
                        </restriction>
                      </simpleType>
                    </element>
                    <element name="assigned_to" type="string" minOccurs="0"/>
                    <element name="estimated_hours" minOccurs="0">
                      <simpleType>
                        <restriction base="decimal">
                          <minInclusive value="0.5"/>
                          <maxInclusive value="999.9"/>
                        </restriction>
                      </simpleType>
                    </element>
                    <element name="due_date" type="date" minOccurs="0"/>
                    <element name="completed_date" type="date" minOccurs="0"/>
                    <element name="tags" minOccurs="0">
                      <complexType>
                        <sequence>
                          <element name="tag" type="string" minOccurs="1" maxOccurs="10"/>
                        </sequence>
                      </complexType>
                    </element>
                    <element name="dependencies" minOccurs="0">
                      <complexType>
                        <sequence>
                          <element name="depends_on" type="string" minOccurs="1" maxOccurs="unbounded"/>
                        </sequence>
                      </complexType>
                    </element>
                    <element name="subtasks" minOccurs="0">
                      <complexType>
                        <sequence>
                          <element name="subtask" minOccurs="1" maxOccurs="20">
                            <complexType>
                              <simpleContent>
                                <extension base="string">
                                  <attribute name="id" type="string" use="required"/>
                                  <attribute name="completed" type="boolean" use="required"/>
                                </extension>
                              </simpleContent>
                            </complexType>
                          </element>
                        </sequence>
                      </complexType>
                    </element>
                  </sequence>
                  <attribute name="id" type="string" use="required"/>
                  <attribute name="project_id" type="string" use="required"/>
                </complexType>
              </element>
            </sequence>
          </complexType>
        </element>

        <element name="time_entries" minOccurs="0">
          <complexType>
            <sequence>
              <element name="entry" minOccurs="0" maxOccurs="unbounded">
                <complexType>
                  <sequence>
                    <element name="date" type="date"/>
                    <element name="hours">
                      <simpleType>
                        <restriction base="decimal">
                          <minInclusive value="0.25"/>
                          <maxInclusive value="24.0"/>
                        </restriction>
                      </simpleType>
                    </element>
                    <element name="description" type="string"/>
                    <element name="user" type="string"/>
                  </sequence>
                  <attribute name="task_id" type="string" use="required"/>
                </complexType>
              </element>
            </sequence>
          </complexType>
        </element>

      </sequence>
    </complexType>
  </element>
</schema>