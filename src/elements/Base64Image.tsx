import React from 'react';
// import PropTypes from 'prop-types';
import { requireNativeComponent } from 'react-native';
import extractProps, { propsAndStyles } from '../lib/extract/extractProps';
import Shape from './Shape';
// import { touchableProps, responderProps } from '../lib/props';
import { NumberProp, ResponderInstanceProps, ResponderProps } from '../lib/extract/types';
import extractResponder from '../lib/extract/extractResponder';

export default class Base64Image extends Shape<{
  scale?: NumberProp;
  dx?: NumberProp;
  dy?: NumberProp;
  base64: string;
  atlasDescriptor: string;
  frameDescriptor: string;
  clipPath: string;
} & ResponderProps
> {
  static displayName = 'Base64Image';

  // now all in responder props?
  // static propTypes = {
  //   ...responderProps,
  //   ...touchableProps,
  //   scale: PropTypes.number,
  //   dx: PropTypes.number,
  //   dy: PropTypes.number,
  //   base64: PropTypes.string.isRequired,
  //   atlasDescriptor: PropTypes.string.isRequired,
  //   frameDescriptor: PropTypes.string.isRequired,
  // };

  static defaultProps = {
    scale: 1,
    dx: 0,
    dy: 0,
    base64: '',
    atlasDescriptor: '',
    frameDescriptor: '',
    clipPath: '',
  };

  // is it required or just old style?
  // setNativeProps = (...args) => {
  //   this.root && this.root.setNativeProps(...args);
  // };

  render() {
    const { props } = this;
    const { scale, dx, dy, base64, atlasDescriptor, frameDescriptor, clipPath } = props;
    return (
      <RNSVGBase64Image
        ref={this.refMethod}
        {...extractResponder(props, this as ResponderInstanceProps)}
        {...extractProps(propsAndStyles(props), this)}
        scale={scale}
        dx={dx}
        dy={dy}
        base64={base64}
        atlasDescriptor={atlasDescriptor}
        frameDescriptor={frameDescriptor}
        clipPath={clipPath}
      />
    );
  }
}

export const RNSVGBase64Image = requireNativeComponent('RNSVGBase64Image');
