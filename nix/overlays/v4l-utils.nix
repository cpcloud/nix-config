{ ... }: _: super: {
  v4l-utils = super.v4l-utils.override {
    withGUI = false;
  };
}
