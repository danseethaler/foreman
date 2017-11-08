import React, { Component } from 'react';

export default class Dropdown extends Component {
  constructor(props) {
    super(props);
    this.state = {
      active: this.props.items[0]
    };
  }

  setSelection = e => {
    e.stopPropagation();
    e.nativeEvent.stopImmediatePropagation();
    e.nativeEvent.stopPropagation();

    const { originalIndex } = e.target.parentNode.dataset;
    const active = this.props.items[originalIndex];

    this.setState({ active });
    return false;
  };

  render() {
    return [
      <label key="label" className="sr-only">
        {this.state.active.title}
      </label>,
      <div key="div" className="input-group-btn">
        <button
          type="button"
          className="btn btn-default dropdown-toggle"
          id="filter"
          data-toggle="dropdown"
          aria-haspopup="true"
          aria-expanded="false"
        >
          {this.state.active.title}
          <span className="caret" />
        </button>
        <ul className="dropdown-menu">
          {this.props.items.map((item, i) => (
            <li
              key={i}
              data-original-index={i}
              className={item.disabled ? 'disabled' : ''}
            >
              <a href="#" onClick={this.setSelection}>
                {item.title}
              </a>
            </li>
          ))}
        </ul>
      </div>
    ];
  }
}
