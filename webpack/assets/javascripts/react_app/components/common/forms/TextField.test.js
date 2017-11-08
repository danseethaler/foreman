// Configure Enzyme
// Configure Enzyme
import Adapter from 'enzyme-adapter-react-16';
import toJson from 'enzyme-to-json';
import { configure, shallow } from 'enzyme';
import React from 'react';

import TextField from './TextField';

configure({ adapter: new Adapter() });

describe('TextField', () => {
  it('should default to a text field', () => {
    const wrapper = shallow(<TextField name="name" type="text" label="Name" />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should render a text area', () => {
    const wrapper = shallow(<TextField name="name" type="textarea" label="Name" />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should render a checkbox', () => {
    const wrapper = shallow(<TextField name="name" type="checkbox" label="Name" />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
