import React from 'react';
import Downshift from './Downshift';
import Dropdown from './Dropdown';

export default ({ filterItems, autocompleteOptions }) => (
  <div className="form-group toolbar-pf-filter">
    <div className="input-group">
      <Dropdown items={filterItems} />
      <Downshift autocompleteOptions={autocompleteOptions} />
    </div>
  </div>
);
