import React from 'react';

const PanelFooter = ({ children, className }) =>
  (
    <div className={`panel-footer ${className || ''}`}>
      {children}
    </div>
  );

export default PanelFooter;
