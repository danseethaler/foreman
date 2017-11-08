import React from 'react';
import Downshift from 'downshift';

export default ({ autocompleteOptions }) => (
  <Downshift onChange={selection => alert(`You selected ${selection}`)}>
    {({
      getInputProps,
      getLabelProps,
      getItemProps,
      isOpen,
      inputValue,
      highlightedIndex,
      selectedItem
    }) => (
      <div>
        <input className="form-control" {...getInputProps()} />
        {isOpen ? (
          <div>
            {autocompleteOptions
              .filter(i => !inputValue || i.includes(inputValue))
              .map((item, index) => (
                <div
                  {...getItemProps({
                    key: item,
                    index,
                    item,
                    style: {
                      backgroundColor:
                        highlightedIndex === index ? 'lightgray' : 'white',
                      fontWeight: selectedItem === item ? 'bold' : 'normal'
                    }
                  })}
                >
                  {item}
                </div>
              ))}
          </div>
        ) : null}
      </div>
    )}
  </Downshift>
);
